<%@ LANGUAGE="VbScript" %>
<html lang="ja">
<head>
    <meta charset="SHIFT-JIF">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>登録結果</title>
</head>
<body>
    <%
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
    Set rs = cnn.Execute("INSERT INTO m_process(process_code, record_type, process_text) VALUES('789', '00', 'test')") %>
    <p>
    <%
    Do
        ' レコードの操作ができるオブジェクト若しくは次のRecordSetがとれず、コネクションが空になった場合終了
        If rs.State = adStateOpen Or rs.ActiveConnection Is Nothing Then
            Exit Do
        End If
        Set rs = rs.NextRecordset()
    Loop

    Set ExecuteUpdate = rs
    cnn.Close
    Set cnn = Nothing
    %>
    <div>
        登録しました！
    </div>

</body>
</html>