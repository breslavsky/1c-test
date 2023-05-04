
&AtClient
Procedure ChangePassword(Command)
	
	If Not NewPassword = ConfirmPassword Then
		
		Message = New UserMessage;
		Message.Text = "Password does not match";
		Message.Field = "ConfirmPassword";
		Message.SetData(ThisObject);
		Message.Message();		
		
		Return;
		
	EndIf;
	
	Close(NewPassword);
	
EndProcedure
