<div id="dlgEnterMultiple">
<form action="pp_compare_results_view.php" method="get">
<textarea name="txtGenes"></textarea>
<input type="submit" value="compare"/>
</form>
</div>
<script type="text/javascript">
  $( function() {
	  $("#dlgEnterMultiple").dialog({title:"Search for multiple genes.", autoOpen:false, modal:true, title:"Compare genes:",
	  open:function() { }

  });
  });
</script>