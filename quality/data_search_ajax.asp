<%@ LANGUAGE="VBScript" codepage=65001 %>
<% Session.CodePage = 65001 %>
<% Response.ContentType = "text/html; charset=UTF-8" %>
<%
    On Error Resume Next
    'DB接続文字列取得
    Set FSO = Server.CreateObject("Scripting.FileSystemObject")
    Set Obj = FSO.OpenTextFile("\\srv-160\wwwroot\gekkeikan\Jozo\iqdb\db\db_config.txt", 1)
    i = 1
    Do until Obj.AtEndOfStream = True
        Select Case i
            Case 1 strDSN = Obj.ReadLine
            Case 2 strUSER = Obj.ReadLine
            Case 3 strPASS = Obj.ReadLine
        End Select
        i = i + 1
    Loop    
    
    'データベースに接続、レコードセットの作成、ストアドの指定
    Set cnn = Server.CreateObject("ADODB.Connection")
    cnn.open "Provider=SQLOLEDB;DATA SOURCE=" & strDSN & ";User ID=" & strUSER & ";Password=" & strPASS
    Set rs = Server.CreateObject("ADODB.Recordset")
    Set cmd = Server.CreateObject("ADODB.Command")
    Set Cmd.ActiveConnection = cnn
    Cmd.CommandText = "usp_search_data"
    Cmd.CommandType = 4

    'パラメータ取得
    strLicense = Replace(Request.queryString("license"), "_", ",")
    If Instr(Request.queryString("sample_date"),"_") > 0 Then
        strStartDate = Left(Request.queryString("sample_date"), 8)
        strEndDate = Right(Request.queryString("sample_date"), 8)
    ElseIF Len(Request.queryString("sample_date")) > 0 Then
        strStartDate = Left(Request.queryString("sample_date"), 8)
        strEndDate = Left(Request.queryString("sample_date"), 8)
    Else
        strStartDate = "20201001"
        strEndDate = "20210111"
    End If
    strLot = Request.queryString("lot")
    strMaterialCode = Request.queryString("material_code")
    strProcessCode = Request.queryString("process_code")
    strRecordCount = Request.queryString("record_count")

    Set par1 = cmd.CreateParameter
    par1.Name = "@License"
    par1.Type = 200
    par1.Size = 100
    par1.Value = strLicense
    par1.Direction = 1
    cmd.Parameters.Append par1

    Set par2 = cmd.CreateParameter
    par2.Name = "@StartDate"
    par2.Type = 200
    par2.Size = 100
    par2.Value = strStartDate
    par2.Direction = 1
    cmd.Parameters.Append par2
    
    Set par3 = cmd.CreateParameter
    par3.Name = "@EndDate"
    par3.Type = 200
    par3.Size = 100
    par3.Value = strEndDate
    par3.Direction = 1
    cmd.Parameters.Append par3
    
    Set par4 = cmd.CreateParameter
    par4.Name = "@Lot"
    par4.Type = 200
    par4.Size = 100
    par4.Value = strLot
    par4.Direction = 1
    cmd.Parameters.Append par4

    Set par5 = cmd.CreateParameter
    par5.Name = "@Material"
    par5.Type = 200
    par5.Size = 100
    par5.Value = strMaterialCode
    par5.Direction = 1
    cmd.Parameters.Append par5

    Set par6 = cmd.CreateParameter
    par6.Name = "@ProcessCode"
    par6.Type = 200
    par6.Size = 100
    par6.Value = strProcessCode
    par6.Direction = 1
    cmd.Parameters.Append par6

    Set par7 = cmd.CreateParameter
    par7.Name = "@RecordCount"
    par7.Type = 200
    par7.Size = 100
    par7.Value = strRecordCount
    par7.Direction = 1
    cmd.Parameters.Append par7

    'ストアド実行してレコードセット取得
    rs.Open cmd, , 0, 1

    'ここにHTMLを追加する処理を記載   

    If rs.EOF Then
        Response.Write("No Record")
    Else
        cnt = 0
        strHtml = ""
        Do Until rs.Eof
            'この中に追加するHTMLを記述
            cnt = cnt + 1
            strHtml = strHtml & "<label for=result" & cnt & " class=result-title>" & rs.Fields("ロット").Value & "  /  " & rs.Fields("品目").Value & "</label>"
            strHtml = strHtml & "<input type=checkbox id=result" & cnt & " class=show-check />"
            strHtml = strHtml & "<div class=show-content>"
            strHtml = strHtml & "<table border=0>"
            For Each fld In rs.Fields
                If fld.Value <> "" Then
                    If fld.Name = "分析結果" Then
                        strData = fld.Value
                        strData = Replace(strData,"""","")
                        strData = Replace(strData,"{","")
                        strData = Replace(strData,"}","")
                        i = 0
                        Do Until strData = "" Or i > 50
                            strName = Left(strData, Instr(strData, ":") - 1)
                            strData = Right(strData, Len(strData) - Instr(strData, ":"))
                            If Instr(strData, ",") > 0 Then
                                strValue = Left(strData, Instr(strData, ",") - 1)
                                strData = Right(strData, Len(strData) - Instr(strData, ","))
                            Else
                                strValue = strData
                                strData = ""
                            End If
                            strHtml = strHtml & "<tr><th class=quality>" & strName & "</th><td class=quality>" & strValue & "</td></tr>"
                            i = i + 1
                        Loop
                    Else
                        strHtml = strHtml & "<tr><th>" & fld.Name & "</th><td>" & fld.Value & "</td></tr>"
                    End If
                End If
            Next
            strHtml = strHtml & "</table></div>"
            rs.MoveNext
        Loop
        Response.Write(strHtml)
    End If
    Set cmd = Nothing
%>