<%@ LANGUAGE="VbScript" codepage=65001 %>
<% Session.CodePage = 65001 %>
<% Response.ContentType = "text/html; charset=UTF-8" %>
<html lang="ja">
<head>
    <!-- ファビコン -->
    <link rel="icon" href="../icon/icon_512×512.ico">        
    <!-- スマホ用アイコン -->
    <link rel="apple-touch-icon" sizes="180x180" href="../icon/icon_192×192.png">

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/default.css">
    <link rel="stylesheet" href="../css/root.css">
    <link rel="stylesheet" href="../css/tasting_merge.css">
    <link rel="stylesheet" href="../css/side_menu.css">
    <title>Tasting Record</title>
</head>
<body>
    
    <header>
        <div class="dummy"></div>
        <div class="title">品質データ検索</div> 
        <div id="nav-drawer">
            <input id="nav-input" type="checkbox" class="nav-unshown">
            <label id="nav-open" for="nav-input"><span></span></label>
            <label class="nav-unshown" id="nav-close" for="nav-input"></label>
            <div id="nav-content">
                <div class="menu"><p>Menu</p>
                    <ul>
                        <li>
                            <a class="menu-button menu-quality" href="../quality/data_search.html">分析データ</a>
                        </li>
                        <li>
                            <a class="menu-button menu-temperature" href="../temperature/temp_search.html">品温データ</a>
                        </li>
                        <li>
                            <a class="menu-button menu-tasting" href="../tasting/login.html">官能検査</a>
                        </li>
                        <!-- <li>
                            <a class="menu-button" href="qr_reader/qr_reader.html">QRコードリーダー</a>
                        </li> -->
                        <li>
                            <a class="menu-button menu-home" href="../index.html">HOME</a>
                        </li>
                    </ul>
            </div>
            </div>
        </div>
        
    </header>
    <main>
    <%
    On Error Resume Next
    strEmployee = Request.Form("employee-code")
    
    Set FSO = Server.CreateObject("Scripting.FileSystemObject")
    Set Obj = FSO.OpenTextFile("\\srv-160\wwwroot\gekkeikan\Jozo\iqdb\db\db_info.txt", 1)
    i = 1
    Do until Obj.AtEndOfStream = True
        Select Case i
            Case 1 strDSN = Obj.ReadLine
            Case 2 strUSER = Obj.ReadLine
            Case 3 strPASS = Obj.ReadLine
        End Select
        i = i + 1
    Loop
    Set cnn = Server.CreateObject("ADODB.Connection")
    cnn.open "Provider=SQLOLEDB;DATA SOURCE=" & strDSN & ";User ID=" & strUSER & ";Password=" & strPASS
    
    cnn.BeginTrans
    
    For i = 1 To Request.Form("count")
        tastingId = Request.Form("tasting-id" & i)
        sampleId = Request.Form("sample-id" & i)
        score = Request.Form("tasting-score" & i)
        
        If score > 0 Then
            strSQL = ""
            strSQL = strSQL & "DECLARE @LOG TABLE (ID int);"
            strSQL = strSQL & "DECLARE @ID int;"
            strSQL = strSQL & " MERGE INTO t_tasting_record t1"
            strSQL = strSQL & " USING ( SELECT "
            strSQL = strSQL & tastingId & " AS tasting_id,"
            strSQL = strSQL & sampleId & " AS sample_id,"
            strSQL = strSQL & strEmployee & " AS employee_code,"
            strSQL = strSQL & score & " AS score"
            strSQL = strSQL & " ) t2"
            strSQL = strSQL & " ON ( t1.tasting_id = t2.tasting_id"
            strSQL = strSQL & " AND t1.employee_code = t2.employee_code)"
            strSQL = strSQL & " WHEN MATCHED THEN"
            strSQL = strSQL & " UPDATE SET"
            strSQL = strSQL & " score= t2.score"
            strSQL = strSQL & " WHEN NOT MATCHED THEN"
            strSQL = strSQL & " INSERT ("
            strSQL = strSQL & " tasting_id,"
            strSQL = strSQL & " sample_id,"
            strSQL = strSQL & " employee_code,"
            strSQL = strSQL & " score"
            strSQL = strSQL & ")"
            strSQL = strSQL & " VALUES ("
            strSQL = strSQL & " t2.tasting_id,"
            strSQL = strSQL & " t2.sample_id,"
            strSQL = strSQL & " t2.employee_code,"
            strSQL = strSQL & " t2.score"
            strSQL = strSQL & ")"
            strSQL = strSQL & " OUTPUT inserted.tasting_record_id INTO @LOG(ID);"
            strSQL = strSQL & " SELECT @ID = ID FROM @LOG;"
        
            commentList = Replace(Replace(Replace(Replace(Request.Form("tasting-comment" & i), "?��?", ","), "??��?", ","), " ", ","), "　", ",")
                 
            If commentList <> "" Then            
                strSQL = strSQL & "DROP TABLE IF EXISTS #comment;"
                strSQL = strSQL & "CREATE TABLE #comment (tasting_record_id int,comment NVARCHAR(max));"
                strSQL = strSQL & "INSERT INTO #comment("
                strSQL = strSQL & " tasting_record_id,"
                strSQL = strSQL & " comment"
                strSQL = strSQL & ")"
                strSQL = strSQL & " VALUES"
                Do Until commentList = ""               
                    If InStr(commentList, ",") = 0 Then
                        comment = commentList
                        commentList = ""
                        strSQL = strSQL & "(@ID,"
                        strSQL = strSQL & "'" & comment & "'"
                        strSQL = strSQL & "),"
                    Else
                        comment = Left(commentList, InStr(commentList, ",") - 1)
                        commentList = Mid(commentList, Len(comment) + 2, Len(commentList))
                        strSQL = strSQL & "(@ID,"
                        strSQL = strSQL & "'" & comment & "'"
                        strSQL = strSQL & "),"
                    End If
                Loop
            
                strSQL = Left(strSQL, Len(strSQL) - 1) & ";"
                strSQL = strSQL & " MERGE INTO t_tasting_record_comment t3"
                strSQL = strSQL & " USING #comment t4"
                strSQL = strSQL & " ON ( t3.tasting_record_id = t4.tasting_record_id"
                strSQL = strSQL & " AND t3.comment = t4.comment)"
                strSQL = strSQL & " WHEN NOT MATCHED THEN"
                strSQL = strSQL & " INSERT ("
                strSQL = strSQL & " tasting_record_id,"
                strSQL = strSQL & " comment"
                strSQL = strSQL & ")"
                strSQL = strSQL & " VALUES ("
                strSQL = strSQL & " t4.tasting_record_id,"
                strSQL = strSQL & " t4.comment)"
                strSQL = strSQL & " WHEN NOT MATCHED BY SOURCE　AND t3.tasting_record_id = @ID THEN"
                strSQL = strSQL & " DELETE;"
            End If
            Set rs = cnn.Execute(strSQL)
            Set rs = Nothing
        End If
    next

    If Err.Number <> 0 Then
        cnn.RollBackTrans
    %>        
    <div class="message error-message">
        <span>記録時にエラーがでました</span>
        <br>
        <span>記録されていません</span>
    </div>
    <%
    Else
        cnn.CommitTrans
    %>
    <div class="message finish-message">
        <span>お疲れ様でした</span>
        <br>
        <span>記録が完了しました</span>
    </div>
    <%
    End If
    cnn.Close
    Set rs = Nothing
    Set Cnn = Nothing
    %>

    <br>
    <br>
    <a href="../index.html">HOME</a>
    </main>
</body>
</html>