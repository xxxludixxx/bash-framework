configLoad "output-formatter-variables.sh";

HEADER="TEST - THIS IS AN EXAMPLE COMMAND";
CONTENT=$( fmtIndent.open && fmtBold.open && fmtPrint.content "./run.sh test " && fmtBold.close;
    fmtPrint.blank;
    fmtItalic.open && fmtIndent.open && fmtPrint.content "Here you can insert a command description. ";
    fmtPrint.blank;
    fmtPrint.content "Here you can provide any information about the command, the usage and any other data";
    fmtPrint.content "What is more, you can simply Lorem ipsum tralalalal.";
    );

fmtInfoSection "$HEADER" "$CONTENT";