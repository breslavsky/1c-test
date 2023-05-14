

Procedure OnStart()
	If CommonFunctionClient.FirstStart() Then
		Exit(False, True);
	ElsIf CommonFunctionClient.TempPassword() Then
		OpenForm("CommonForm.Login",,,,,,,FormWindowOpeningMode.LockWholeInterface);
	Endif;	
EndProcedure
