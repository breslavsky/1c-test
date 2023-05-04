
Procedure BeforeStart(Cancel)
	
	CurrentUser = Users.AuthorizedUser();
	Cancel = Users.IsInvalidUser(CurrentUser);
	
	If Cancel Then 
		
		Return;
		
	EndIf;
	
EndProcedure

Procedure OnStart()
	
	If Users.IsSetTemporaryPassword(Users.CurrentUser()) Then
		
		OpenForm("CommonForm.ChangePassword",,,,,, New NotifyDescription("ChangePasswordEnd", UserClient), FormWindowOpeningMode.LockWholeInterface);
		
	EndIf;
	
EndProcedure
