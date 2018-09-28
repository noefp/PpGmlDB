

-- Creating phonetic table for annotation table.
DROP TABLE IF EXISTS "public"."annotation_phonetic";

CREATE table "public"."annotation_phonetic" (
	annot_phonetic_id bigserial not null primary key,
	annotation_id bigint not null,
	phoneticDesc text not null,
	constraint fk_anot_phonetic_to_annot foreign key (annotation_id) references "public"."annotation" (annotation_id)
);

-- Function which returns the phonetic code of a text. It's using a modified cologne phonetics algorithm- instead of 1-8 and - it's using a-i. The 0 is never added so removal is not necessarry. 
CREATE OR REPLACE FUNCTION getPhoneticCode(stringToEncode TEXT)
RETURNS TEXT as $$
DECLARE 
	lowerString TEXT;
	i INTEGER=1;
	last TEXT;
	current TEXT;
	next TEXT;
	result text = '';
	newCharAtCurrentPos text ='';
BEGIN
	SELECT lower(stringToEncode) INTO lowerString	;
	SELECT ' ' INTO current;
	SELECT substring(lowerString,i,1) INTO next;

	WHILE (i<=char_length(stringToEncode)) LOOP
		SELECT current INTO last;
		SELECT next INTO current;
		i:=i+1;
		SELECT substring(lowerString,i,1) INTO next;
		IF(current='a' OR current ='e' OR current = 'i' OR current = 'o' OR current = 'u' OR current ='ö' OR current = 'ü' OR current = 'ä') THEN
			if(last='' OR last=' ') THEN
				newCharAtCurrentPos='a';
			ELSE
				newCharAtCurrentPos='';
			END IF;
		ELSIF (current='h') THEN
			newCharAtCurrentPos:='a';
		ELSIF (current='b') THEN
			newCharAtCurrentPos :='b';
		ELSIF (current = 'p' AND next <> 'h') THEN
			newCharAtCurrentPos='b';
		ELSIF (current='d' OR current='t') THEN
			IF (next <> 'c' and next <> 's' and next <> 'z')  THEN 
				newCharAtCurrentPos='c';
			ELSE
				newCharAtCurrentPos='i';
		END IF;
		ELSIF (current = 'f' or current = 'v' or current ='w') THEN
			newCharAtCurrentPos='d';
		ELSIF (current='p' and next = 'h') THEN
			newCharAtCurrentPos='d';
		ELSIF (current='g' or current = 'h' or current ='q') THEN
			newCharAtCurrentPos='e';
		ELSIF (current='c') THEN 
			IF ((last = '' OR last=' ') AND (next = 'a' OR next='h' OR next='k' or next='l' or next='o' or next ='q' or next='r' or next='u' or next='x')) THEN
				newCharAtCurrentPos='e';
			ELSIF (next='a' or next='h' or next='k' or next='o' or next='q'  or next='u' or next='x') and (last <>'s' and last <>'z')
			THEN
				newCharAtCurrentPos='e';
			ELSIF (last='s' OR last='z') THEN
				newCharAtCurrentPos='i';
			ELSIF (last = '' or last= ' ') and (next <>'a' AND next <>'h' and next <>'k' and next <>'l' and next <>'o' and next <> 'q' and next <> 'r' and next <> 'u' and next <> 'x') THEN
				newCharAtCurrentPos='i';
			ELSIF (next <>'a' AND next<>'h' AND next <>'k' AND next <>'o' AND next <>'q' AND next <>'u' AND next <>'u' AND next<>'x') THEN
				newCharAtCurrentPos='i';
			END IF;
		ELSIF (current='x' and (last<>'c' and last <>'k' and last <>'q')) THEN
			newCharAtCurrentPos='ei';
		ELSIF (current='l') THEN
			newCharAtCurrentPos='f';
		ELSIF	(current ='m' OR current ='n') THEN
			newCharAtCurrentPos='g';
		ELSIF (current = 'r') THEN
			newCharAtCurrentPos='h';
		ELSIF (current='s' OR current='z') THEN
			newCharAtCurrentPos='i';
		ELSIF (current='x' and (last='c' OR last ='k' OR last ='q')) THEN
			newCharAtCurrentPos='i';
		
		ELSE
			newCharAtCurrentPos := current;
		END IF;
		result:=result || newCharAtCurrentPos;
	END LOOP;
	return result;
END;
$$ language plpgsql;

-- Creating triggers which update the phonetics table after update or insert on annotation.

CREATE OR REPLACE FUNCTION updateAnnotationPhonetic()
	RETURNS trigger AS $updateAnnotationPhonetic$
BEGIN
	update "public"."annotation_phonetic"
		set phoneticDesc=getPhoneticCode(new.annot_desc)
		where annotation_id=new.annotation_id;
	return new;
END;
$updateAnnotationPhonetic$ LANGUAGE plpgsql;

DROP trigger updateAnnotationPhonetic on "public"."annotation";
CREATE  trigger updateAnnotationPhonetic after update on "public"."annotation"
	FOR EACH ROW EXECUTE PROCEDURE updateAnnotationPhonetic();
	
	
CREATE  OR REPLACE FUNCTION insertAnnotationPhonetic()
	RETURNS trigger AS $insertAnnotationPhonetic$
BEGIN
	insert into "public"."annotation_phonetic"
		(annotation_id,phoneticDesc) values(new.annotation_id,getPhoneticCode(new.annot_desc));
	return new;
END;
$insertAnnotationPhonetic$ LANGUAGE plpgsql;

DROP trigger IF EXISTS insertAnnotationPhonetic ON "public"."annotation";
CREATE  trigger insertAnnotationPhonetic after insert on "public"."annotation"
	FOR EACH ROW EXECUTE PROCEDURE insertAnnotationPhonetic();

-- Inserting data added to annotation before trigger was created.	
INSERT INTO "public"."annotation_phonetic" (annotation_id, phoneticDesc)
		 SELECT annotation_id, getPhoneticCode(annot_desc)
		 FROM "public"."annotation";