&AtClient
Procedure CloseWindowLogin()
	If Not OK Then
		Exit(False);
	EndIf;	
EndProcedure
	
&AtClient
Procedure CancelPassword(Command)
	CloseWindowLogin();
EndProcedure

&AtClient
Procedure Cancel(Command)
	CloseWindowLogin();
EndProcedure
	
&AtClient
Procedure Login(Command)
	retValue = LoginAtServer();
	If retValue = 0 Then
		Items.DecorationInfo.Visible = True;
		Items.DecorationInfo.Title = "Login or password entered incorrectly";
	ElsIf retValue = 1 Then
		OK = TRUE;
		ThisForm.Close();
	ElsIf retValue = 2 Then
		Items.GroupMain.Visible = False;
		Items.GroupNewPassword.Visible = True;
	ElsIf retValue = 3 Then
		Items.DecorationInfo.Visible = True;
		Items.DecorationInfo.Title = "The employee was found by the entered login";
	ElsIf retValue = 4 Then
		Items.DecorationInfo.Visible = True;
		Items.DecorationInfo.Title = "Access closed. Employee already fired";
	EndIf;	
EndProcedure

&AtClient
Procedure OnClose(Exit)
	CloseWindowLogin();
EndProcedure

&AtClient
Procedure SavePassword(Command)
	If NewPassword = PasswordConfirm Then
		SavePasswordAtServer();
		OK = TRUE;
		ThisForm.Close();
	Else
		Items.DecorationInfo.Visible = True;
		Items.DecorationInfo.Title = "New and verification passwords do not match";
	EndIf;			
EndProcedure

&AtServer
Procedure SavePasswordAtServer()
	Manager = InformationRegisters.RegistrationData.CreateRecordManager();
	Manager.Employee = Employee;
	Manager.Password = NewPassword;
	Manager.TemporaryPassword = False;
	Manager.Write(True);
EndProcedure



&AtServer
Function LoginAtServer()
	Query = New Query;
	Query.SetParameter("Login", Login);
	Query.Text = "SELECT
	|	Employees.Ref AS Employee
	|FROM
	|	Catalog.Employees AS Employees
	|WHERE
	|	Employees.Description = &Login";
	Selection = Query.Execute().Select();
	If Not Selection.Next() Then
		Employee = Login;
		RetVal = 3;
	Else
		Employee = Selection.Employee;
		RetVal = 0;
	EndIf;
	
	Query.SetParameter("Employee", Employee);
	Query.SetParameter("Password", Password);
	Query.Text = "SELECT
	|	RegistrationData.TemporaryPassword,
	|	RegistrationData.IsLeave
	|FROM
	|	InformationRegister.RegistrationData AS RegistrationData
	|WHERE
	|	RegistrationData.Employee = &Employee
	|	AND RegistrationData.Password = &Password";
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		If Selection.TemporaryPassword Then
			RetVal = 2;
		ElsIf Selection.isLeave Then
			RetVal = 4;
		Else
			RetVal = 1;
		EndIf;
	EndIf;	
	Return RetVal;
EndFunction

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Selection = InformationRegisters.RegistrationData.Select();
	If Not Selection.Next() Then
		Manager = InformationRegisters.RegistrationData.CreateRecordManager();
		Manager.Employee = "Administrator";
		Manager.TemporaryPassword = True;
		Manager.Password = "12345678";
		Manager.IsLeave = False;
		Manager.Write();
	EndIf;		
	SynchronizationEmployees.SynkEmployees();
EndProcedure

