 
 Procedure ChangePasswordEnd(Result, AdditionalParameters) Export
	 
	If Not TypeOf(Result) = Type("String") Then
		Exit(False);		 
	EndIf;
	
	User = Users.CurrentUser();
	
	If Not Users.SetPassword(User, Result) Then
		Exit(False);	
	EndIf;
	
	Users.DeleteTemporaryPassword(User);
	
	ShowUserNotification("Password changed");
	
 EndProcedure
 