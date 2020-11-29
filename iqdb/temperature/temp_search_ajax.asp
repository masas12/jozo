<%@ LANGUAGE="VBScript" codepage=65001 %>
<% Session.CodePage = 65001 %>
<% Response.ContentType = "text/html; charset=UTF-8" %>
<%  
    On Error Resume Next

    strType = Request.queryString("type")
    strBrewery = Request.queryString("brewery")

    If strType = "" Or strBrewery = "" Then
        strHtml = "No Record"
    Else
        Set FSO = Server.CreateObject("Scripting.FileSystemObject")
        strFolderPath = Server.MapPath(".")
        strDirName = strFolderPath & "\" & strType & "\" & strBrewery
        Set objDIR = FSO.GetFolder(strDirName)

        strHtml = ""
        i = 1
        For Each f In objDIR.Files
            strFileName = f.Name  'ファイル名を取り出します
            strShikomiNo = Mid(strFileName, 1, 4)
            strNissu = Mid(strFileName, 6, 2)
            strTankNo = Mid(strFileName, 9, 4)

            strHtml = strHTML & "<div class='data-frame'>"
            strHtml = strHTML & "<div class='data-label'>"
            strHtml = strHTML & "<div id='shikomi-no-" & i & "'>" & strShikomiNo & "号</div>"
            strHtml = strHTML & "<div>" & strNissu & "日目</div>"
            strHtml = strHTML & "<div>タンクNo" & strTankNo & "</div>"
            strHtml = strHTML & "</div>"
            strHtml = strHTML & "<div class='data-chart'>"
            strHtml = strHTML & "<canvas class='chart' id='myChart-" & i & "'></canvas>"
            strHtml = strHTML & "</div>"
            strHtml = strHTML & "</div>"

            i = i + 1
        Next

        If Err.Number <> 0 Then
            strHtml = "No Record"
        End If
    End If

    Response.Write(strHtml)
%>