<div id="dlgEnterMultiple" class="modal fade" role="dialog" tabIndex=-1 aria-labelledby="Enter gene identifiers to search":" >
  <div class="modal-dialog" role="document">
	<div class="modal-content">
		<div class="modal-header">
			<h5 class="modal-title" id="exampleModalLabel">Enter gene identifiers to search:</h5>
			<button type="button" class="close" data-dismiss="modal" aria-label="Close">
				<span aria-hidden="true">&times;</span>
			</button>
		</div>
		<div class="modal-body">
			
			<form method="get" action="pp_compare_results_view.php">
				<textarea name="txtGenes" id="txtGenes"></textarea>
				<input type="checkbox" name="chkShowAnnot">Show annotations</input>
				<?php 
				include_once "pp_search_gene_version_input.php";
				getCheckboxes("chkGenesModalId", "chkVersionName");
				?>
				<input type="submit" class="btn btn-search">search</input>
			</form>
		</div>
		<div class="modal-footer">
		</div>
	</div>
</div>
</div>
