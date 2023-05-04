
Procedure DefineCurrentUser(Val ParameterName, SetParameters) Export

	SetPrivilegedMode(True);
	
	If Not ParameterName = "CurrentUser" Then 
		Return;
	EndIf;
	
	UserNotFound = Ложь;
	CreateUser  = Ложь;
	
	If IsBlankString(InfoBaseUsers.CurrentUser().Name) Then
		
		If IsFullUser() Then			
			
			UserName = UnspecifiedUserFullName();
			UserFullName = UnspecifiedUserFullName();

			
			Query = New Query;
			Query.Text = 
				"SELECT TOP 1
				|	Users.Ref AS Ref
				|FROM
				|	Catalog.Users AS Users
				|WHERE
				|	Users.Description = &Description";
			
			Query.SetParameter("Description", UserFullName);
			
			Result = Query.Execute();

			If Result.IsEmpty() Then
				
				UserNotFound = True;
				CreateUser  = True;
				IBUserID = "";
				
			Else
				
				Selection = Result.Select();
				Selection.Next();
				SessionParameters.CurrentUser = Selection.Ref;
				
			EndIf;
			
		Else
			
			UserNotFound = True;
			
		EndIf;

	Else

		IBUserID = InfoBaseUsers.CurrentUser().UUID;
	
		Query = New Query;
		Query.Text = 
			"SELECT TOP 1
			|	Users.Ref AS Ref
			|FROM
			|	Catalog.Users AS Users
			|WHERE
			|	Users.IBUserID = &IBUserID";
		Query.SetParameter("IBUserID", IBUserID);
		
		ResultUsers = Query.Execute();
		
		If ResultUsers.IsEmpty() Then
			
			CurrentUser = InfoBaseUsers.CurrentUser();
			UserName = CurrentUser.Name;
			UserFullName = CurrentUser.FullName;
			IBUserID = CurrentUser.UUID;
			UserByFullName  = RefUserByFullName(UserFullName);
			
			If UserByFullName = Undefined Then
				
				UserNotFound = True;
				CreateUser  = True;
				
			Else
				
				SessionParameters.CurrentUser = UserByFullName;
				
			EndIf;
			
		Else
			
			Selection = ResultUsers.Select();
			Selection.Next();
			SessionParameters.CurrentUser = Selection.Ref;
			
		EndIf;
		
	EndIf;
	
	If CreateUser Then
		
		NewObjectRef = Catalogs.Users.GetRef();
		SessionParameters.CurrentUser = NewObjectRef;
		
		NewUser = Catalogs.Users.CreateItem();
		NewUser.IBUserID = IBUserID;
		NewUser.Description = UserFullName;
		NewUser.SetNewObjectRef(NewObjectRef);
		
		Try
			
			NewUser.Write();
			
		Except
			
			ErrorMessage = StrTemplate(NStr("en = 'Authorization failed.
	                                      |User: %1 not found in catalog ""Users"".
	                                      |
	                                      |Contact the administrator.
	                                      |An error occurred when adding a user to catalog.
	                                      |%2'"),
				                           UserName,
				                           BriefErrorDescription(ErrorInfo()));	   
			Raise ErrorMessage;
			
		EndTry;
	
	ElsIf UserNotFound Then
		
		ErrorMessage = StrTemplate(NStr("en = 'Authorization failed. The system operation will be completed.
	                                    |
	                                    |User ""%1"" was not found in the catalog ""Users"".
	                                    |
	                                    |Contact the administrator.'"),
										UserName);
		
		Raise ErrorMessage;
		
	EndIf;
	
	SetParameters.Add(ParameterName);
	
EndProcedure

Function IsFullUser(User = Undefined) Export

	SetPrivilegedMode(True);
	
	If ValueIsFilled(User) And User <> AuthorizedUser() Then 
		
		IBUser = InfoBaseUsers.FindByUUID(Common.ObjectAttributeValue(User, "IBUserID"));
		
		If IBUser = Undefined Then
			
			Return False;
			
		EndIf;
		
	Else
		
		IBUser = InfoBaseUsers.CurrentUser();
		
	EndIf;
	
	If IBUser.UUID = InfoBaseUsers.CurrentUser().UUID Then
		
		If ValueIsFilled(IBUser.Name) Then
			
			Return IsInRole("FullAccess") Or InfoBaseUsers.FindByUUID(InfoBaseUsers.CurrentUser().UUID).Roles.Contains(Metadata.Roles.FullAccess);
			
		Else
			
			If Metadata.DefaultRoles.Count() = 0 Then
				
				Return True;
				
			Else
				
				For Each DefaultRole In Metadata.DefaultRoles Do
					
					If DefaultRole = Metadata.Roles.FullAccess Then
						
						Return True;
						
					EndIf;
					
				EndDo;
				
				Return False;
				
			EndIf;
			
		EndIf;
		
	Else
		
		Return IBUser.Roles.Contains(Metadata.Roles.FullAccess);
		
	EndIf;
	
EndFunction

Function AuthorizedUser() Export
	
	SetPrivilegedMode(True);
	Return SessionParameters.CurrentUser;
	
EndFunction

Function CurrentUser() Export
	
	Return AuthorizedUser();
	
EndFunction

Function UnspecifiedUserFullName() Export
	
	Return "<" + NStr("en = 'Not specified';") + ">";
	
EndFunction

Function RefUserByFullName(Val FullName)

	SetPrivilegedMode(True);
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	Users.Ref AS Ref,
		|	Users.IBUserID AS IBUserID
		|FROM
		|	Catalog.Users AS Users
		|WHERE
		|	Users.Description = &FullName";
	Query.SetParameter("FullName", FullName);
	
	QueryResult = Query.Execute();

	If QueryResult.IsEmpty() Then
		
		Return Undefined;	                        	
		
	EndIf;
		
	Selection = QueryResult.Select();
	Selection.Next();
	
	User = Selection.Ref;
	IBUserID = Selection.IBUserID;
	
	If IBUserNotOccupied(IBUserID) Then
		
		Return User;
		
	EndIf;
	
	Return Undefined;
	
EndFunction

Function IBUserNotOccupied(Val IBUser) Export
	
	SetPrivilegedMode(True);
	
	IBUser = InfoBaseUsers.FindByName(IBUser);

	If IBUser = Undefined Then
		
		Return True;
		
	EndIf;
	
	If UserByIDExists(IBUser.UUID) Then 
		
		Return False;	
		
	Else 
		
		Return True;
		
	EndIf;
	
EndFunction

Function UserByIDExists(UUID, RefToCurrent = Undefined) Export 

	SetPrivilegedMode(True);
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	Users.Ref AS Ref
		|FROM
		|	Catalog.Users AS Users
		|WHERE
		|	Users.Ref <> &RefToCurrent
		|	AND Users.IBUserID = &IBUserID";
	
	Query.SetParameter("IBUserID", UUID);
	Query.SetParameter("RefToCurrent", RefToCurrent);
	
	Return Not Query.Execute().IsEmpty();

EndFunction

Function IsInvalidUser(User) Export 
	
	LeaveDate = Common.ObjectAttributeValue(User, "LeaveDate");
	
	Return ValueIsFilled(LeaveDate) And LeaveDate < CurrentSessionDate();	

EndFunction

Function UserExists(Val UserName, Val Exclusion = Undefined) Export
	
	SetPrivilegedMode(True);
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	Users.Ref AS Ref
		|FROM
		|	Catalog.Users AS Users
		|WHERE
		|	Users.Description = &UserName
		|	AND Users.Ref <> &Exclusion";
	
	Query.SetParameter("Exclusion", Exclusion);
	Query.SetParameter("UserName", UserName);
	
	Return Not Query.Execute().IsEmpty();

EndFunction

Function GetRole(Val RoleCode) Export  
	
	SetPrivilegedMode(True);
	
	Roles = New Map;
	Roles.Insert("account_manager", Metadata.Roles.AccountManager); 
	Roles.Insert("client_solutions_head", Metadata.Roles.HeadOfClientSolutions);
	Roles.Insert("project_manager", Metadata.Roles.ProjectManager);
	Roles.Insert("content_manager", Metadata.Roles.ContentManager);
	Roles.Insert("analyst", Metadata.Roles.Analyst);
	Roles.Insert("accounter", Metadata.Roles.Accounter);
	Roles.Insert("finance_director", Metadata.Roles.FinanceDirector);

	Return Roles.Get(RoleCode);	

EndFunction

Function GeneratedPassword() Export
	
	Milliseconds = CurrentUniversalDateInMilliseconds();
	InitialNumber = Milliseconds - Int(Milliseconds / 40) * 40;
	RNG = New RandomNumberGenerator(InitialNumber);
	
	Password = "";
	UsingCharacters = "*#01243456789AQWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm";
	N = StrLen(UsingCharacters);
	
	While StrLen(Password) < 7 Do
		
		Symbol = Mid(UsingCharacters, (RNG.RandomNumber(1, N)), 1);
		Password = Password + Symbol;
		
	EndDo;        
	
	Return Password;

EndFunction

Function IsSetTemporaryPassword(User) Export
	
	SetPrivilegedMode(True);
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	TemporaryPasswords.Password AS Password
		|FROM
		|	InformationRegister.TemporaryPasswords AS TemporaryPasswords
		|WHERE
		|	TemporaryPasswords.User = &User";
	Query.SetParameter("User", User);
	Return Not Query.Execute().IsEmpty();

EndFunction

Function SetPassword(User, Val Password) Export 
	
	SetPrivilegedMode(True);
	
	IBUser = InfoBaseUsers.FindByUUID(Common.ObjectAttributeValue(User, "IBUserID"));
	
	If IBUser = Undefined Then
		
		Return False;
		
	EndIf;
	
	IBUser.Password = Password;
	IBUser.Write();
	
	Return True;

EndFunction

Procedure DeleteTemporaryPassword(User) Export 
	
	SetPrivilegedMode(True);
	
	Record = InformationRegisters.TemporaryPasswords.CreateRecordManager();
	Record.User = User;
	Record.Read();
	
	If Record.Selected() Then
		
		Record.Delete();
		
	EndIf;

EndProcedure
 
