table 50024 E_Invoice_Log
{
    DataClassification = ToBeClassified;
    LookupPageId = "E-Invoice Log";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Invoice,"Credit Memo";
        }
        field(3; "G_IRN Sent Request"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "G_IRN Output Response"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "QR Code"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
        field(6; "IRN Hash"; text[64])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Acknowledge No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Acknowledge Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Current Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "IRN Status"; Enum "Irn Status")
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Irn Cancel Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Error Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "C_IRN Sent Request"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
        field(15; "C_IRN Output Response"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
        field(16; "E-Way Bill No"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "E-Way Bill Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "G_E-Way bill Sent Request"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
        field(19; "G_E-Way bill Output Response"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
        field(20; "E-Way Bill Status"; Enum "E-Way Bill Status")
        {
            DataClassification = ToBeClassified;
        }
        field(21; "E-Way Bill Cancel DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "E-Way Bill Cancel Request"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
        }
        field(23; "E-Way Bill Cancel Output"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.", "Line No")
        {
            Clustered = true;
        }
    }

    procedure GenerateIRNSentResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("G_IRN Sent Request");
        "G_IRN Sent Request".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure GenerateIRNOutPutResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("G_IRN Output Response");
        "G_IRN Output Response".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure CancelIRNSentResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("C_IRN Sent Request");
        "C_IRN Sent Request".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure CancelIRNOutPutResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("C_IRN Output Response");
        "C_IRN Output Response".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure GenerateEWayBillSentResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("G_E-Way bill Sent Request");
        "G_E-Way bill Sent Request".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure GenerateEWayBillOutPutResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("G_E-Way bill Output Response");
        "G_E-Way bill Output Response".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure CancelEWayBillSentResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("E-Way Bill Cancel Request");
        "E-Way Bill Cancel Request".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;

    procedure CancelEWayBillOutPutResponseReadAsText(LineSeparator: Text; Encoding: TextEncoding) Content: Text
    var
        InStream: InStream;
        ContentLine: Text;
    begin
        CALCFIELDS("E-Way Bill Cancel Output");
        "E-Way Bill Cancel Output".CREATEINSTREAM(InStream, Encoding);

        InStream.READTEXT(Content);
        WHILE NOT InStream.EOS DO BEGIN
            InStream.READTEXT(ContentLine);
            Content += LineSeparator + ContentLine;
        END;
    end;
}