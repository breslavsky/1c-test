
Procedure BeforeWrite(Cancel)
	
	If Users.UserExists(Description, Ref) Then
		
		Cancel = True;
		
		Message = New UserMessage;
		Message.Text = "User with this name already exists";
		Message.Message();
		
		Return;
		
	EndIf;	
		
EndProcedure
