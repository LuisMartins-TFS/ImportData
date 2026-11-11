page 60707 "File Browser Lookup"
{
    Caption = 'File Browser';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BLOB File";
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(FileNameGroup)
            {
                Caption = 'File Name';

                field(NewFileName; NewFileName)
                {
                    Caption = 'File Name';
                    ApplicationArea = All;
                    ToolTip = 'Enter the name of the new file.';
                }
            }
            repeater(ItemList)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Displays the name of the file.';

                    trigger OnDrillDown()
                    var
                        FileBrowser: Page "File Browser";
                        FileMgmt: Codeunit "File Management";
                    begin
                        if Rec.Type = Rec.Type::Folder then begin
                            CurrentFolder := Rec.ID;
                            SelectedFile := Rec.ID;
                            UpdateList();
                        end else begin
                            SelectedFile := Rec.ID;
                            UpdateList();
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GoBack)
            {
                Caption = 'Back';
                ApplicationArea = All;
                Image = PreviousRecord;
                ToolTip = 'Go back to the previous folder.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    BlobFile: Record "BLOB File";
                begin
                    BlobFile.Reset();
                    BlobFile.SetRange(ID, CurrentFolder);
                    if BlobFile.FindFirst() then
                        CurrentFolder := BlobFile."Parent ID";
                    UpdateList();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        UpDateList();
    end;

    procedure GetSelectedFile(): Integer
    begin
        exit(SelectedFile);
    end;

    procedure GetFileToSave(var lFileName: Text[50]; var lFolder: Integer)
    begin
        lFolder := CurrentFolder;
        lFileName := NewFileName;
    end;

    local procedure UpdateList()
    var
        BlobFile: Record "BLOB File";
    begin
        newFileName := Rec.Name;
        BlobFile.Reset();
        BlobFile.SetRange("Parent ID", CurrentFolder);
        if BlobFile.FindSet() then
            CurrPage.SetTableView(BlobFile);
        CurrPage.Update();
    end;

    var
        CurrentFolder: Integer;
        SelectedFile: Integer;
        NewFileName: Text[50];
}