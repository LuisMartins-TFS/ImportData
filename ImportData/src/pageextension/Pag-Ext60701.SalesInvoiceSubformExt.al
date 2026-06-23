pageextension 60701 "Sales Invoice Subform Ext" extends "Posted Sales Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addbefore(DocAttach)

        {
            action("Distribution")
            {
                ApplicationArea = All;
                Caption = 'Distribution';
                Image = Excel;
                ToolTip = 'This action is for distribution purposes.';
                trigger OnAction()
                var
                lpDistributionOrders:Page "Distribution for sales invoice";
                begin
                    lpDistributionOrders.SalesLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}