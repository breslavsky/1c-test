Function FirstStart() Export
	FirstStart = False;
	If Constants.ServerData.Get() = "" then
		Constants.ServerData.Set("cdn.jsdelivr.net");
		Constants.PathToFileSynchronization.Set("gh/breslavsky/1c-test@v1.0.0/employees.json");	
		CreateAdministartor();
		FirstStart = True;	
	EndIf;	
	Return FirstStart;
EndFunction

Procedure CreateAdministartor() 
	Manager = InformationRegisters.RegistrationData.CreateRecordManager();
	Manager.Employee = "Administrator";
	Manager.TemporaryPassword = True;
	Manager.Password = "12345678";
	Manager.IsLeave = False;
	Manager.Write();
	CreateUser(New Structure("Name, Password, FullName", "Administrator", "12345678", "Administrator"), True);
EndProcedure

Function FindRole(Description)
	Role = Undefined;
	For Each MetaRole In Metadata.Roles Do
		If MetaRole.Synonym = Description Then
			Role = MetaRole;
			Break; 
		EndIf;	
	EndDo;	
	Return Role;
EndFunction	

Function CreateUser(PropUser, FullAccess) Export
	InfobaseUser =InfoBaseUsers.FindByName(PropUser.Name); 
	If InfobaseUser <> Undefined Then
		InfobaseUser.ShowInList = True;
		InfobaseUser.StandardAuthentication = True;
		If PropUser.Property("Roles") And PropUser.Roles.Count() Then
			InfobaseUser.Roles.Clear();
			For Each Prop In PropUser.Roles Do
				Role = FindRole(Prop);
				If Role <> Undefined Then
					InfobaseUser.Roles.Add(Role);
				EndIf;
			EndDo;	
		EndIf;
		InfobaseUser.Write();
		Return False;
	EndIf;
	NewUser = InfoBaseUsers.CreateUser();
	FillPropertyValues(NewUser, PropUser);
	If FullAccess Then
		NewUser.Roles.Add(Metadata.Roles.FullAccess);
	ElsIf PropUser.Property("Roles") And PropUser.Roles.Count() Then
		For Each Prop In PropUser.Roles Do
			Role = FindRole(Prop);
			If Role <> Undefined Then
				NewUser.Roles.Add(Role);
			EndIf;	
		EndDo;	
	EndIf;	
	NewUser.Write();
	Return True;
EndFunction

Function OffUser(PropUser, FullAccess) Export
	InfobaseUser =InfoBaseUsers.FindByName(PropUser.Name); 
	If InfobaseUser <> Undefined Then
		Return False;
	EndIf;
	InfobaseUser.ShowInList = False;
	InfobaseUser.StandardAuthentication = False;
	Return True;
EndFunction

Function TempPassword() Export
	Employee = FindEmployeeForUser();
	Query = New Query;
	Query.SetParameter("Employee", Employee);
	Query.Text = "SELECT
	|	RegistrationData.TemporaryPassword
	|FROM
	|	InformationRegister.RegistrationData AS RegistrationData
	|WHERE
	|	RegistrationData.Employee = &Employee";
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.TemporaryPassword;
	Else
		Return False;
	EndIf; 
EndFunction	

Function FindEmployeeForUser() Export
	Employee = Catalogs.Employees.FindByCode(InfoBaseUsers.CurrentUser().Name);
	If Employee.IsEmpty() Then
		Employee = InfoBaseUsers.CurrentUser().Name;
	Endif;		
	Return Employee;
EndFunction		 	