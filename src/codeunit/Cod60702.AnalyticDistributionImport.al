codeunit 60702 "Analytic Distribution Import"
{
    trigger OnRun()
    begin
    end;

    procedure ImportVehicleDistribution(pDocumentNo: Code[20]; pLine: Integer; pType: Enum "Distribution type") lOk: Boolean
    var
        lrSelectedReg: Record "Analytic distribution";
        CommonDialogMgt: Codeunit "File Management";
        lrtempAnalyticDistribution: Record "Analytic distribution";
        TFSSetup: Record "TFS Setup";
        FromFile: Text[100];
        IStream: InStream;
        FileName: Text[100];
        SheetName: Text[100];
        UploadExcelMsg: Label 'Please Choose the Excel file.';
        NoFileFoundMsg: Label 'No Excel file found!';
        ExcelImportSucess: Label 'Excel is successfully imported.';
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
    begin
        // TFSSetup.Get();
        UploadIntoStream(UploadExcelMsg, '', '', FromFile, IStream);
        if FromFile <> '' then begin
            FileName := CommonDialogMgt.GetFileName(FromFile);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(IStream);
        end else
            Error(NoFileFoundMsg);
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(IStream, SheetName);
        TempExcelBuffer.ReadSheet();

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        lrtempAnalyticDistribution.Reset();
        lrtempAnalyticDistribution.SetRange("Document No.", pDocumentNo);
        lrtempAnalyticDistribution.SetRange(Line, pLine);
        lrtempAnalyticDistribution.SetRange(Type, pType);
        if lrtempAnalyticDistribution.FindLast() then
            LineNo := lrtempAnalyticDistribution.Sequence;
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then begin
            MaxRowNo := TempExcelBuffer."Row No.";
        end;
        lrtempAnalyticDistribution.Reset();
        lrtempAnalyticDistribution.SetRange("Document No.", pDocumentNo);
        lrtempAnalyticDistribution.SetRange(Line, pLine);
        lrtempAnalyticDistribution.SetRange(Type, pType);
        if lrtempAnalyticDistribution.FindSet() then
            repeat
                lrtempAnalyticDistribution.Delete();
            until lrtempAnalyticDistribution.Next() = 0;

        for RowNo := 2 to MaxRowNo do begin
            LineNo := LineNo + 1;
            lrtempAnalyticDistribution.Init();
            lrtempAnalyticDistribution.Validate(Type, pType);
            lrtempAnalyticDistribution.VALIDATE("Document No.", pDocumentNo);
            lrtempAnalyticDistribution.VALIDATE(Line, pLine);
            lrtempAnalyticDistribution.validate(Sequence, LineNo);
            // lrtempAnalyticDistribution.Validate("Dimension 1", TFSSetup."Vehicle dimension");
            lrtempAnalyticDistribution.Validate("Dimension 1", 'VEHICLE');
            Evaluate(lrtempAnalyticDistribution."Dimension value 1", GetValueAtCell(RowNo, 1));
            Evaluate(lrtempAnalyticDistribution.Amount, GetValueAtCell(RowNo, 3));
            lrtempAnalyticDistribution.Amount := ROUND(lrtempAnalyticDistribution.Amount, 0.01);
            lrtempAnalyticDistribution.Insert();
        end;
        Message(ExcelImportSucess);
        exit(true);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin

        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TFSSetup: Record "TFS Setup";
}