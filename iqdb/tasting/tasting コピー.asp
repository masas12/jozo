<%@ LANGUAGE="VbScript" %>
<html lang="ja">
<head>
    <meta charset="SHIFT-JIF">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- ファビコン -->
    <link rel="icon" href="../icon/icon_512×512.ico">        
    <!-- スマホ用アイコン -->
    <link rel="apple-touch-icon" sizes="180x180" href="../icon/icon_192×192.png">

    <link rel="stylesheet" href="../css/root.css">
    <link rel="stylesheet" href="../css/default.css">
    <link rel="stylesheet" href="../css/tasting.css">

    <title>利き酒フォーム</title>

<!--オレオレ証明書ではPWAにはできない？ 
    <link rel="manifest" href="../manifest.json">
    <script>
        if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('../sw.js');
        }
    </script> -->
</head>
<body>        
    <%
    On Error Resume Next
    strLicense = "'" & Request.Form("license") & "'"
    strEmployee = "'" & Request.Form("employee") & "'"
    strTastingGroup = "'%'"

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
    strSQL = ""
    strSQL = strSQL & " SELECT * FROM v_tasting_sample_now v"
    strSQL = strSQL & " LEFT OUTER JOIN (select * from v_tasting_record where employee_code = " & strEmployee  & ") t"
    strSQL = strSQL & " ON v.利き酒ID = t.tasting_id"
    strSQL = strSQL & " WHERE v.免許地コード = " & strLicense 
    strSQL = strSQL & " AND v.利き酒グループコード LIKE " & strTastingGroup 
    strSQL = strSQL & " ORDER BY v.サンプルID;"
    Set rs = cnn.Execute(strSQL)
    Set rs2 = cnn.Execute("SELECT employee_text FROM m_employee WHERE employee_code = " & strEmployee  & ";")
    Set rs3 = cnn.Execute("SELECT * FROM m_tasting_comment_default ORDER BY tasting_comment_code;")
    Set rs4 = cnn.Execute("SELECT TOP (10) comment FROM v_tasting_comment_rank ORDER BY total_count DESC;")
    strSQL = ""
    strSQL = strSQL & " SELECT TOP (10) comment ,count(*) AS total_count" & _
                                " FROM v_tasting_record_comment" & _
                                " WHERE employee_code = '" & employee & "'" & _
                                " GROUP BY employee_code,comment" & _
                                " ORDER BY total_count DESC;"
    Set rs5 = cnn.Execute(strSQL)
    
    If rs.EOF Then %>        
        <div Class="error">利き酒サンプルが見つかりません
            <p>
                <a class="error-back" href="login.html">ログイン画面に戻る</a>
            </p>
        </div>
    <% 
    Else
    IF rs2.EOF Then %>
        <div Class="error">社員コード:<%= strEmployee %>が見つかりません
            <p>
                <a class="error-back" href="login.html">ログイン画面に戻る</a>
            </p>
        </div>
    <%
    ELSE
    If Err.Number > 0 Then %>
        <p><%= Err.Number %></p>
        <p><%= Err.Description %></p>
    <% End If %>
    
    <header>
        <div class="space"></div>
        <div class="title">官能検査</div>
        <div class="user-name"><%= rs2.Fields("employee_text").value %></div>
    </header>

    <main>        
        <form class="tasting" action="tasting_merge.asp" method="post" name="my-form">
            <ul>
                <% i = 1 %>
                <% Do While Not rs.EOF %>
                    <li>
                        <div class="item">
                            <div class="item-info"> 
                                <input type="hidden" name="tasting-id<%= i %>" value="<%= rs.Fields("利き酒ID").value %>">
                                <input type="hidden" name="sample-id<%= i %>" value="<%= rs.Fields("サンプルID").value %>">
                                <span>ID:<%= rs.Fields("サンプルID").value %></span>
                                <span>工程:<%= rs.Fields("工程").value %></span>
                                <span>品目:<%= rs.Fields("品目").value %></span>
                                <span>Lot:<%= rs.Fields("ロット").value %></span>
                            </div>
                            <div class="score-group">
                                <div class="scores">
                                    <span>1</span>
                                    <span>2</span>
                                    <span>3</span>
                                    <span>4</span>
                                    <span>5</span>
                                </div>
                                <div class="scores">
                                    <% Select Case rs.Fields("score").value %>
                                        <% Case 1 %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1" Checked="Checked">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5">
                                        <% Case 2 %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2" Checked="Checked">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5">
                                        <% Case 3 %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3" Checked="Checked">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5">
                                        <% Case 4 %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4" Checked="Checked">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5">
                                        <% Case 5 %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5" Checked="Checked">
                                        <% Case Else %>
                                            <input type="radio" id="score1-<%= i %>" name="tasting-score<%= i %>" value="1">
                                            <input type="radio" id="score2-<%= i %>" name="tasting-score<%= i %>" value="2">
                                            <input type="radio" id="score3-<%= i %>" name="tasting-score<%= i %>" value="3">
                                            <input type="radio" id="score4-<%= i %>" name="tasting-score<%= i %>" value="4">
                                            <input type="radio" id="score5-<%= i %>" name="tasting-score<%= i %>" value="5">
                                    <% End Select %>
                                </div>
                            </div>
                            <div class="comment-group">
                                <input class="comment" id="comment<%= i %>" type="text" name="tasting-comment<%= i %>" Value="<%= rs.Fields("comment_list").value %>">
                                <span class="plus" id="plus<%= i %>" onclick="accordionShow(<%= i %>)"><img src="../icon/plus.png" alt="+" height="20" width="20"></span>
                                <div class="list" id="list<%= i %>"><ul class="comment-list" id="comment-list<%= i %>">
                                    <% rs3.MoveFirst %>
                                    <% Do While Not rs3.EOF %>
                                        <li class="aroma" onclick="commentPush(<%= i %>, this)"><%= rs3.Fields("tasting_comment").Value %></li>
                                        <% rs3.MoveNext %>
                                    <% Loop %>
                                </ul></div>
                            </div>
                        </div>
                    </li>
                    <% rs.MoveNext %>
                    <% i = i + 1 %>
                <% Loop %>       
            </ul>
            <p class="count-group">
                <span>計</span>
                <input class="count" type="text" name="count" value="<%= i - 1 %>" readonly="readonly">
                <span>件</span>
            </p>
            <input class="employee-code" type="hidden" name="employee-code" value="<%= strEmployee %>" readonly="readonly">
            <p class="submit">
                <input id="1" class="submit-button" type="submit" value="記録">
            </p>
        </form>
    </main>
    <%         
    rs.Close            
    rs2.Close            
    cnn.Close
    End If
    End If %>
    <script src="../js/accordion_show.js"></script>
    <script src="../js/comment_push.js"></script>
</body>
</html>