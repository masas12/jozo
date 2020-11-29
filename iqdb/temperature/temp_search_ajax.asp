<%@ LANGUAGE="VBScript" codepage=65001 %>
<% Session.CodePage = 65001 %>
<% Response.ContentType = "text/html; charset=UTF-8" %>
<%  
    strType = "moromi"
    Set FS = Server.CreateObject("Scripting.FileSystemObject")
    strDirName = Server.MapPath(".\" & strType & "\" & strBrewery) 'フォルダ名の取得
    Set strDIR = FS.GetFolder(strDirName)

    strHTML = ""
    For Each f In sDIR.Files
        sFileName = f.Name  'ファイル名を取り出します
    ' ファイル名を使った処理
    '
    Next

    strHtml = "No Record"

    Response.Write(strHtml)
%>