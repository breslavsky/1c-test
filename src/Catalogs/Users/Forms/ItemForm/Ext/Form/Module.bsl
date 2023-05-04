
&AtServer
Procedure OnReadAtServer(CurrentObject)
	
	IBUser = InfoBaseUsers.FindByUUID(Common.ObjectAttributeValue(Object.Ref, "IBUserID"));
	
	For Each Role In IBUser.Roles Do
		
		NewString = Roles.Add();
		NewString.Role = ?(ValueIsFilled(Role.Synonym), Role.Synonym, Role.Name);		
	
	EndDo;
	
EndProcedure
