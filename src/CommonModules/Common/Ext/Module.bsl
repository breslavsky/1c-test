
Function ObjectAttributesValues(Ref, Val Attributes) Export
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	" + Attributes + "
		|FROM
		|	" + Ref.Metadata().FullName() + " AS Table
		|WHERE
		|	Table.Ref = &Ref";
	Query.SetParameter("Ref", Ref);

	Selection = Query.Execute().Select();
	Selection.Next();
	
	Result = New Structure(Attributes);
	FillPropertyValues(Result, Selection);	
	
	Return Result;
	
EndFunction

Function ObjectAttributeValue(Ref, AttributeName) Export

	Result = ObjectAttributesValues(Ref, AttributeName);
	Return Result[AttributeName];
	
EndFunction 

