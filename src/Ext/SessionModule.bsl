
Procedure SessionParametersSetting(RequiredParameters)

	If Not RequiredParameters = Undefined Then
		
		SetParameters = New Array;
		
		For Each ParameterName In RequiredParameters  Do
        	SetValueOfParameterSession(ParameterName, SetParameters);
		EndDo;
		
	EndIf;
	
EndProcedure

Procedure SetValueOfParameterSession(Val ParameterName, SetParameters)
	
	If Not SetParameters.Find(ParameterName) = Undefined Then 
		Return;
	EndIf;	   
	
	Users.DefineCurrentUser(ParameterName, SetParameters);	

EndProcedure
