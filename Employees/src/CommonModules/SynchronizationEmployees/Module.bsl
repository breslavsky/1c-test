Procedure SynkEmployees() Export
	SecureConn = New OpenSSlSecureConnection(New WindowsClientCertificate(), 
		New WindowsCertificationAuthorityCertificates);
	Connection = New HTTPConnection(Constants.ServerData.Get(),443,,,,,SecureConn);
	Headers = New Map();
	Headers.Insert("Content-Type", "text/html");
	Answer = Connection.Get(New HTTPRequest(Constants.PathToFileSynchronization.Get(), Headers));
	TextJSON = Answer.GetBodyAsString();
	If TextJSON = Undefined Then
		WriteLogEvent("Synk", EventLogLevel.Error,,,"Failed to get data from web resource: " + Constants.PathToFileSynchronization.Get());
		Return;
	Else	
		WriteLogEvent("Synk", EventLogLevel.Information,,,"Read text from answer: " + Chars.LF + TextJSON);
	Endif;
	Structure = ReadJSONFromText(TextJSON);
	If Structure.Count() = 0 Then
		WriteLogEvent("Synk", EventLogLevel.Error,,,"Failed to populate response structure from JSON: " + TextJSON);
		Return;
	Else
		For Each RowSynk In Structure.Employees Do
			refEmployee = Catalogs.Employees.FindByCode(RowSynk.code);
			isNew = False;
			isLeave = False;
			If refEmployee.IsEmpty() Then
				newEmployee = Catalogs.Employees.CreateItem();
				newEmployee.Code = RowSynk.code;
				isNew = True; 
			Else
				newEmployee = refEmployee.GetObject();	
			EndIf;	
			newEmployee.FirstName = RowSynk.first_name;
			newEmployee.LastName  = RowSynk.last_name;
			newEmployee.Description = newEmployee.FirstName + " " + newEmployee.LastName;
			newEmployee.HireDate  = DateFromString(RowSynk.hire_date);
			If TrimR(RowSynk.leave_date) <> "" Then
				newEmployee.LeaveDate  = DateFromString(RowSynk.leave_date);
				isLeave = True;
			EndIf;	
			newEmployee.Roles.Clear();
			For Each Role In RowSynk.Roles Do
				NewRow = newEmployee.Roles.Add();
				NewRow.Role = Role;
			EndDo;
			newEmployee.Write();
			If isNew Then
				Manager = InformationRegisters.RegistrationData.CreateRecordManager();
				Manager.Employee = newEmployee.Ref;
				Manager.TemporaryPassword = True;
				Manager.Password = "12345678";
				Manager.IsLeave = False;
				Manager.Write();
				If Not CommonFunctionServer.CreateUser(New Structure("Name, FullName, Password, Roles", RowSynk.code, newEmployee.Description, "12345678", RowSynk.Roles), False) Then
					WriteLogEvent("Synk", EventLogLevel.Information,,,"User access for " + RowSynk.code + " has been restored.");
				Endif;
			ElsIf isLeave Then
				Manager = InformationRegisters.RegistrationData.CreateRecordManager();
				Manager.Employee = newEmployee.Ref;
				Manager.TemporaryPassword = False;
				Manager.IsLeave = True;
				Manager.Write(True);
				If Not CommonFunctionServer.OffUser(New Structure("Name, FullName, Password, Roles", RowSynk.code, newEmployee.Description, "12345678", RowSynk.Roles), False)Then
					WriteLogEvent("Synk", EventLogLevel.Warning,,,"No found user: " + RowSynk.code);
				EndIf;
			Else	
				Manager = InformationRegisters.RegistrationData.CreateRecordManager();
				Manager.Employee = newEmployee.Ref;
				Manager.TemporaryPassword = False;
				Manager.IsLeave = False;
				Manager.Write(True);
				If Not CommonFunctionServer.CreateUser(New Structure("Name, FullName, Password, Roles", RowSynk.code, newEmployee.Description, "12345678", RowSynk.Roles), False) Then
					WriteLogEvent("Synk", EventLogLevel.Information,,,"User access for " + RowSynk.code + " has been restored.");
				Endif;
			EndIf;
		EndDo;
		WriteLogEvent("Synk", EventLogLevel.Information,,,"Added/edited entries " + Structure.Employees.Count() + " to the catalog 'Employees'");
	EndIf		
EndProcedure

Function DateFromString(leave_date)
	strDate = TrimR(leave_date);
	If strDate = "" Then
		Return Undefined;
	Endif;
	Return Date(StrReplace(strDate,"-", "") + "000000");	
EndFunction
 
Function ReadJSONFromText(TextJSON) Export
	Reader = Новый JSONReader;
	Reader.SetString(TextJSON);
	Structure = FillStructureFromJSON(Reader);	
	Reader.Close();
	Return Structure;
EndFunction

Function FillStructureFromJSON(Val Reader) 
	Result = New Structure;

	LastName = Undefined;
	
	While Reader.Read() Do
		Type = Reader.CurrentValueType;
		If Type = JSONValueType.НачалоОбъекта И LastName<>Undefined Then 
			Result[LastName] = FillStructureFromJSON(Reader);
		ElsIf Type = JSONValueType.КонецОбъекта Then 
			Return Result;
			LastName = Undefined;
		ElsIf Type = JSONValueType.PropertyName Then 
			Result.Insert(Reader.CurrentValue, Undefined);
			LastName = Reader.CurrentValue;
		ElsIf Type = JSONValueType.Boolean OR Type = JSONValueType.String
			OR Type = JSONValueType.Number OR Type = JSONValueType.Null Then 
			Result[LastName] = Reader.CurrentValue;
		ElsIf Type = JSONValueType.ArrayStart Then  
			If LastName = Undefined Then
				LastName = "Employees";
				Result.Insert(LastName, FillArrayJSON(Reader));
			Else	
				Result[LastName] = FillArrayJSON(Reader);
			EndIf;	
		EndIf;
	EndDo;  
		
	Return Result;
EndFunction 

Function FillArrayJSON(Val Reader)
	Result = New Array;
	
	While Reader.Read() Do
		Type = Reader.CurrentValueType;
		If Type = JSONValueType.ObjectStart Then 
			Result.Добавить(FillStructureFromJSON(Reader));
		ElsIf Type = JSONValueType.Boolean OR Type = JSONValueType.String
			OR Type = JSONValueType.Number OR Type = JSONValueType.Null Then 
			Result.Добавить(Reader.CurrentValue);
		ElsIf Type = JSONValueType.ArrayEnd Then 
			Return Result;
		EndIf;
	EndDo;  
	Return Result;
EndFunction	      


 