<%@ LANGUAGE="VbScript" %>
<html lang="ja">
<head>
    <meta charset="SHIFT-JIF">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>ID�w��</title>
</head>
<body>
    <% 
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
    Set cnn = Server.CreateObject("ADODB.Connection")
    Set rs = Server.CreateObject("ADODB.Recordset")
    cnn.open "Provider=SQLOLEDB;DATA SOURCE=" & strDSN & ";User ID=" & strUSER & ";Password=" & strPASS
    Set cmd = Server.CreateObject("ADODB.Command")
    Set Cmd.ActiveConnection = cnn
    Cmd.CommandText = "usp_tasting_table"
    Cmd.CommandType = 4

    Set par1 = cmd.CreateParameter
    par1.Name = "@License"
    par1.Type = 200
    par1.Size = 100
    par1.Value = "07"
    par1.Direction = 1
    cmd.Parameters.Append par1
    
    Set par2 = cmd.CreateParameter
    par2.Name = "@TastingGroup"
    par2.Type = 200
    par2.Size = 100
    par2.Value = "%"
    par2.Direction = 1
    cmd.Parameters.Append par2

    rs.Open cmd, , 0, 1 %>

    <p>
    <table border=1>
        <tr>
            <% For i = 0 to rs.Fields.Count - 1 %>
            <td>
                <b><% = rs(i).Name %></b>
            </td>
            <% Next %>
        </tr>
        <% Do While Not rs.EOF %>
        <tr>
            <% For i = 0 to RS.Fields.Count - 1 %>
            <td><% = rs(i) %></td>
            <% Next %>
        </tr>
        <%
        rs.MoveNext
        Loop
        rs.Close
        cnn.Close
        %>
    </table>
    <br>
    <br>
    <a href="insert.asp">�V�K�o�^</a>
</body>
</html>