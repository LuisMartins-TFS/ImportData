page 60702 "Distribution for sales invoice"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Analytic distribution";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Total; rec.Amount)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field(Distributed; Distributed)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Distributed field.';
                }
                field(Remaining; Remaining)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Remaining field.';
                }
            }
            repeater(Detail)
            {
                field(Vehicle; rec."Dimension value 1")
                {
                    ToolTip = 'Specifies the value of the Dimension value 1 field.';
                }
                field(Amount; rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportDistribution)
            {
                ToolTip = 'Executes the Import action.';
                trigger OnAction()
                var
                    cImportDistribution: Codeunit "Analytic Distribution Import";
                    Error60508001: Label 'Import failed. Please verify import file';
                    EntryType: Enum "Distribution type";
                begin
                    EntryType := EntryType::"Sales invoice";
                    IF cImportDistribution.ImportVehicleDistribution(rec."Document No.", rec."Line", EntryType) then begin
                        Distributed := DistributionTotal();
                        Remaining := rec.Amount - Distributed;
                    end else
                        Error(Error60508001);
                end;
            }
        }
    }
    procedure SalesLine(SalesRec: Record "Sales Invoice Line") lOK: Boolean
    var
    begin
        rLine := SalesRec;
    end;

    var
        Distributed: Decimal;
        Remaining: Decimal;
        rLine: Record "Sales Invoice Line";
        rDistribution: Record "Analytic distribution";
        TotalDist: Decimal;


    local procedure DistributionTotal() lTotalDist: Decimal
    var
        lAnalyticDistribution: Record "Analytic distribution";
    begin
        lAnalyticDistribution.SETRANGE(Type, lAnalyticDistribution.Type::"Sales invoice");
        lAnalyticDistribution.SETRANGE("Document No.", rec."Document No.");
        lAnalyticDistribution.SETRANGE(Line, rec."Line");
        IF lAnalyticDistribution.FINDSET THEN BEGIN
            lTotalDist := 0;
            REPEAT
                lTotalDist += lAnalyticDistribution.Amount;
            UNTIL lAnalyticDistribution.NEXT = 0;
        END;
        EXIT(lTotalDist);
    end;

    trigger OnOpenPage()
    begin
        TFSSetup.GET;
        Rec.SETRANGE(Type, Rec.Type::"Sales invoice");
        Rec.SETRANGE("Document No.", rLine."Document No.");
        Rec.SETRANGE(Line, rLine."Line No.");
        IF Rec.FINDSET THEN BEGIN
            Remaining := rLine."Line Amount" - DistributionTotal();
            Distributed := DistributionTotal();
        END;
    end;

    trigger OnNewRecord(belowxRec: Boolean)
    begin
        IF Rec.Sequence = 0 THEN BEGIN
            rDistribution.SETRANGE(Type, Rec.Type::"Sales invoice");
            rDistribution.SETRANGE("Document No.", rLine."Document No.");
            rDistribution.SETRANGE(Line, rLine."Line No.");
            IF rDistribution.FINDLAST THEN
                Rec.Sequence := rDistribution.Sequence;
        END;
        Rec.Sequence += 100;
        Rec.Type := Rec.Type::"Sales invoice";
        Rec."Document No." := rLine."Document No.";
        Rec.Line := rLine."Line No.";
        Rec."Dimension 1" := TFSSetup."Vehicle dimension";
        Rec."Original dimension value 1" := rline."Shortcut Dimension 1 Code";
        TotalDist := DistributionTotal();
        rec."Not distributed amount" := rLine."Line Amount" - TotalDist;
        Remaining := rLine."Line Amount" - DistributionTotal();
        Distributed := DistributionTotal();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Remaining := Remaining - xRec.Amount + rec.Amount;
        Distributed := Distributed + xRec.Amount - Rec.Amount;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Remaining := Remaining + Rec.Amount;
        Distributed := Distributed - rec.Amount;
    end;

    trigger OnQueryClosePage(closeAction: Action): Boolean
    var
        TextConf001: Label 'The full amount has not been distributed! Do you want to leave?';
        Error60508002: Label 'Amount distributed is higher than the remaining amount';
    begin
        rDistribution.SETRANGE(Type, rDistribution.Type::"Sales invoice");
        rDistribution.SETRANGE("Document No.", rLine."Document No.");
        rDistribution.SETRANGE(Line, rLine."Line No.");
        IF rDistribution.FINDSET THEN BEGIN
            TotalDist := 0;
            REPEAT
                TotalDist += rDistribution.Amount;
            UNTIL rDistribution.NEXT = 0;
        END;
        IF TotalDist > rLine."Line Amount" THEN
            ERROR(Error60508002);
        IF TotalDist < rLine."Line Amount" THEN
            IF NOT CONFIRM(TextConf001, TRUE) THEN
                ERROR('');
        rDistribution.RESET;
        rDistribution.SETRANGE(Type, rDistribution.Type::"Sales invoice");
        rDistribution.SETRANGE("Document No.", rLine."Document No.");
        rDistribution.SETRANGE(Line, rLine."Line No.");
        rDistribution.SETRANGE("Dimension 1", '');
        IF NOT rDistribution.ISEMPTY THEN
            rDistribution.DELETEALL;
    end;

    var
        TFSSetup: Record "TFS Setup";
}