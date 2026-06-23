page 60710 "Distribution Test"
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
                field(Total; rLine.Amount)
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
                    EntryType: Enum "Distribution type";
                begin
                    EntryType := EntryType::"Sales order";
                    IF cImportDistribution.ImportVehicleDistribution(rLine."Document No.", rLine."Line No.", EntryType) then begin
                        Distributed := DistributionTotal();
                        Remaining := rLine."Line Amount" - Distributed;
                    end else
                        Error('Import failed. Please verify import file');
                end;
            }
        }
    }
    procedure SalesLine(SalesRec: Record "Sales Line") lOK: Boolean
    var
        myInt: Integer;
    begin
        rLine := SalesRec;
    end;

    var
        Distributed: Decimal;
        Remaining: Decimal;
        rLine: Record "Sales Line";
        rDistribution: Record "Analytic distribution";
        TotalDist: Decimal;


    local procedure DistributionTotal() lTotalDist: Decimal
    var
        lAnalyticDistribution: Record "Analytic distribution";
    begin

        lAnalyticDistribution.SETRANGE(Type, lAnalyticDistribution.Type::"Sales order");
        lAnalyticDistribution.SETRANGE("Document No.", rLine."Document No.");
        lAnalyticDistribution.SETRANGE(Line, rLine."Line No.");
        IF lAnalyticDistribution.FINDSET THEN BEGIN
            lTotalDist := 0;
            REPEAT
                lTotalDist += lAnalyticDistribution.Amount;
            UNTIL lAnalyticDistribution.NEXT = 0;
        END;
        EXIT(lTotalDist);
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin

        // rTFSSetup.GET;
        Rec.SETRANGE(Type, Rec.Type::"Sales order");
        Rec.SETRANGE("Document No.", rLine."Document No.");
        Rec.SETRANGE(Line, rLine."Line No.");
        IF Rec.FINDSET THEN BEGIN
            Remaining := rLine."Line Amount" - DistributionTotal();
            Distributed := DistributionTotal();
        END;
    end;

    trigger OnNewRecord(belowxRec: Boolean)
    var
        myInt: Integer;
    begin

        IF Rec.Sequence = 0 THEN BEGIN
            rDistribution.SETRANGE(Type, Rec.Type::"Sales order");
            rDistribution.SETRANGE("Document No.", rLine."Document No.");
            rDistribution.SETRANGE(Line, rLine."Line No.");
            IF rDistribution.FINDLAST THEN
                Rec.Sequence := rDistribution.Sequence;
        END;
        Rec.Sequence += 100;
        Rec.Type := Rec.Type::"Sales order";
        Rec."Document No." := rLine."Document No.";
        Rec.Line := rLine."Line No.";
        Rec."Dimension 1" := 'VEICULO';
        Rec."Original dimension value 1" := rline."Shortcut Dimension 1 Code";
        TotalDist := DistributionTotal();
        rec."Not distributed amount" := rLine."Line Amount" - TotalDist;
        Remaining := rLine."Line Amount" - DistributionTotal();
        Distributed := DistributionTotal();
    end;

    trigger OnModifyRecord(): Boolean
    var
        myInt: Integer;
    begin

        Remaining := Remaining - xRec.Amount + rec.Amount;
        Distributed := Distributed + xRec.Amount - Rec.Amount;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        myInt: Integer;
    begin

        Remaining := Remaining + Rec.Amount;
        Distributed := Distributed - rec.Amount;
    end;

    trigger OnQueryClosePage(closeAction: Action): Boolean
    var
        myInt: Integer;
    begin

        rDistribution.SETRANGE(Type, rDistribution.Type::"Sales order");
        rDistribution.SETRANGE("Document No.", rLine."Document No.");
        rDistribution.SETRANGE(Line, rLine."Line No.");
        IF rDistribution.FINDSET THEN BEGIN
            TotalDist := 0;
            REPEAT
                TotalDist += rDistribution.Amount;
            UNTIL rDistribution.NEXT = 0;
        END;
        IF TotalDist > rLine."Line Amount" THEN
            ERROR('Valor distribuido é superior ao valor por distribuir');
        IF TotalDist < rLine."Line Amount" THEN
            IF NOT CONFIRM('Nao foi distribuida a totalidade do valor! Pretende sair?', TRUE) THEN
                ERROR('');
        rDistribution.RESET;
        rDistribution.SETRANGE(Type, rDistribution.Type::"Sales order");
        rDistribution.SETRANGE("Document No.", rLine."Document No.");
        rDistribution.SETRANGE(Line, rLine."Line No.");
        rDistribution.SETRANGE("Dimension 1", '');
        IF NOT rDistribution.ISEMPTY THEN
            rDistribution.DELETEALL;
    end;

    var
        rTFSSetup: Record "TFS Setup";
}