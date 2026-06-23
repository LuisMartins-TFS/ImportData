codeunit 60700 "Export Requisition EDI"
{
    trigger OnRun()
    var
        CompanyInfo: Record "Company Information";
        TFSSetup: Record "TFS Setup";
        ExportReq: XmlPort "Send Requisitions to Serviroda";
        rAdInf: Record "Entity aditional information";
        Vendor: Record Vendor;
        FileData: File;
        FileDataOS: OutStream;
        FileCheck: File;
        RegVal: InStream;
        BlobFile: record "BLOB File";
        Trash: Text[250];
        iCount: Integer;
        Valid: Boolean;
        SelectDate: Date;
        DateAlf, HourAlf, TxtNameBegin, DirExp, DirHistExp, DirScripts : Text[250];
        flagInterrupt: Boolean;
        TextExportZ: Label 'ZASREQ';
        TextExportT: Label 'TFSREQ';
        ConfirmExecution: Label 'Pretende executar a exportacao das requisiçoes para a Serviroda?';
        "60530Error001": Label 'A pasta de localizacao do ficheiro nao está definida para o fornecedor %1';
        "60530Error002": Label 'A pasta de Historico nao está definida para o fornecedor %1';
        ConfirmScripts: Label 'A pasta de scripts nao está definida.Pretende continuar?';
        "60530Error003": Label 'Processo cancelado';
    begin

        IF CONFIRM(ConfirmExecution, false) THEN
            ERROR('');

        CompanyInfo.GET;
        TFSSetup.GET();
        SelectDate := WORKDATE;

        flagInterrupt := FALSE;
        DateAlf := FORMAT(WORKDATE, 0, '<Day,2><Month,2><Year4>');
        HourAlf := FORMAT(TIME, 0, '<Hour,2><Minutes,2><Seconds,2>');

        IF CompanyInfo.Initials = 'ZAS' THEN
            TxtNameBegin := TextExportZ + DateAlf
        ELSE
            IF CompanyInfo.Initials = 'TFS' THEN
                TxtNameBegin := TextExportT + DateAlf;

        IF Vendor.GET(TFSSetup."Serviroda vendor no.") THEN BEGIN
            rAdInf.RESET;
            rAdInf.SETRANGE("Entity Type", rAdInf."Entity Type"::Vendor);
            rAdInf.SETRANGE(Code, TFSSetup."Serviroda vendor no.");
            IF rAdInf.FINDLAST THEN BEGIN
                IF rAdInf."Export folder" = '' THEN
                    ERROR("60530Error001", TFSSetup."Serviroda vendor no.")
                ELSE
                    DirExp := rAdInf."Export folder";
                IF rAdInf."History export folder" = '' THEN
                    ERROR("60530Error002", TFSSetup."Serviroda vendor no.")
                ELSE
                    DirHistExp := rAdInf."History export folder";
                IF rAdInf."External scripts folder" <> '' THEN
                    DirScripts := rAdInf."External scripts folder" + 'serviroda_envio.bat'
                ELSE
                    IF NOT CONFIRM(ConfirmScripts, TRUE) THEN
                        ERROR("60530Error003");
            END;
        END;

            //    ExportReq.FILENAME(DirExp + TxtNameBegin + HourAlf + '.csv');
            //     CLEAR(BlobFile);
            //     BlobFile.CREATE(DirExp + TxtNomeIni + HoraAlf + '.csv');
            //     FileData.CREATEOUTSTREAM(FileDataOS);
            //     ExportReq.SETDESTINATION(FileDataOS);
            //     ExportReq.EXPORT;
            //     FileData.CLOSE;
            //     iCount := 0;
            //     Valido := FALSE;
            //     FileCheck.OPEN(DirExp + TxtNomeIni + HoraAlf + '.csv');
            //     FileCheck.CREATEINSTREAM(RegVal);
            //     WHILE NOT (RegVal.EOS()) AND (Valido = FALSE) DO BEGIN
            //         RegVal.READTEXT(Lixo);
            //         iCount += 1;
            //         IF iCount >= 1 THEN
            //             Valido := TRUE;
            //     END;
            //     FileCheck.CLOSE();
            //     IF Valido = FALSE THEN
            //         FILE.ERASE(DirExp + TxtNomeIni + HoraAlf + '.csv');
    end;
}