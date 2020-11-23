<%@ LANGUAGE="VbScript" codepage=65001 %>
<% Session.CodePage = 65001 %>
<% Response.ContentType = "text/html; charset=UTF-8" %>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- ファビコン -->
    <link rel="icon" href="../icon/icon_512×512.ico">        
    <!-- スマホ用アイコン -->
    <link rel="apple-touch-icon" sizes="180x180" href="../icon/icon_192×192.png">

    <link rel="stylesheet" href="../css/root.css">
    <link rel="stylesheet" href="../css/default.css">
    <link rel="stylesheet" href="../css/tasting.css">

    <title>IQDB-官能検査</title>

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
    Set rs = Server.CreateObject("ADODB.Recordset")
    Set cmd = Server.CreateObject("ADODB.Command")
    Set Cmd.ActiveConnection = cnn
    Cmd.CommandText = "usp_tasting_sample"
    Cmd.CommandType = 4

    Set par1 = cmd.CreateParameter
    par1.Name = "@EmployeeCode"
    par1.Type = 200
    par1.Size = 100
    par1.Value = Request.Form("employee")
    par1.Direction = 1
    cmd.Parameters.Append par1

    Set par2 = cmd.CreateParameter
    par2.Name = "@License"
    par2.Type = 200
    par2.Size = 100
    par2.Value = Request.Form("license")
    par2.Direction = 1
    cmd.Parameters.Append par2
    
    Set par3 = cmd.CreateParameter
    par3.Name = "@TastingGroupCode"
    par3.Type = 200
    par3.Size = 100
    par3.Value = "%"
    par3.Direction = 1
    cmd.Parameters.Append par3

    rs.Open cmd, , 0, 1
    Set rs2 = cnn.Execute("SELECT employee_text FROM m_employee WHERE employee_code = " & strEmployee  & ";")
    Set rs3 = cnn.Execute("SELECT * FROM m_tasting_comment_default ORDER BY tasting_comment_code;")
    Set rs4 = cnn.Execute("SELECT TOP (20) comment FROM v_tasting_comment_rank ORDER BY total_count DESC;")
    strSQL = ""
    strSQL = strSQL & " SELECT TOP (20) comment ,count(*) AS total_count" & _
                                " FROM v_tasting_record_comment" & _
                                " WHERE employee_code = " & strEmployee & _
                                " GROUP BY employee_code,comment" & _
                                " ORDER BY total_count DESC;"
    Set rs5 = cnn.Execute(strSQL)
    
    If rs.EOF Then %>        
        <div Class="error">該当のサンプルがありません。
            <p>
                <a class="error-back" href="login.html">ログイン画面に戻る</a>
            </p>
        </div>
    <% 
    Else
    IF rs2.EOF Then %>
        <div Class="error">社員コード：<%= strEmployee %>が見つかりません。
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
    
    <header id="header">
        <div class="space"></div>
        <div class="title">官能検査</div>
        <div class="user-name"><%= rs2.Fields("employee_text").value %></div>
    </header>

    <div class="modal" id="modal">
        <div>
            <span class="label">サンプルID</span>
            <br>
            <input class="selected-id" id="selected-id" type="text" value="">
            <img class="close" onclick="modalClose()" src="../icon/close.png" alt="×" height="25" width="25">
        </div>
        <span class="label">選択したコメント</span>
        <br>
        <input class="selected-comment" id="selected-comment" type="text" value="">
        <div class="container">
            <div class="select-btns" id="comment-group-btn">
                <div>
                    <input type="radio" id="default-btn" value="1" name="comment-btn" onclick="changeList('total')">
                    <label>Total</label>
                </div>
                <div>
                    <input type="radio" value="2" name="comment-btn" onclick="changeList('aroma')">
                    <label>Aroma</label>
                </div>
                <div>
                    <input type="radio" value="3" name="comment-btn" onclick="changeList('taste')">
                    <label>Taste</label>
                </div>
                <div>
                    <input type="radio" value="4" name="comment-btn" onclick="changeList('trend')">
                    <label>Trend</label>
                </div>
                <div>
                    <input type="radio" value="5" name="comment-btn" onclick="changeList('history')">
                    <label>History</label>
                </div>
            </div>
        </div>
        <div class="list-block">
            <% rs3.Filter = "comment_group = '総合・色沢'" %>
            <% rs3.MoveFirst %>
            <ul class="comment-list" id="total">

                <% Do While Not rs3.EOF %>
                    <li class="comment-word" onclick="commentPush(<%= i %>, this)"><span><%= rs3.Fields("tasting_comment").Value %></span></li>    
                    <% rs3.MoveNext %>
                <% Loop %>
            </ul>
            <% rs3.Filter = "comment_group = '香り'" %>
            <% rs3.MoveFirst %>
            <ul class="comment-list" id="aroma">
                <% Do While Not rs3.EOF %>
                    <li class="comment-word" onclick="commentPush(<%= i %>, this)"><span><%= rs3.Fields("tasting_comment").Value %></span></li>    
                    <% rs3.MoveNext %>
                <% Loop %>
            </ul>
            <% rs3.Filter = "comment_group = '味'" %>
            <% rs3.MoveFirst %>
            <ul class="comment-list" id="taste">
                <% Do While Not rs3.EOF %>
                    <li class="comment-word" onclick="commentPush(<%= i %>, this)"><span><%= rs3.Fields("tasting_comment").Value %></span></li>    
                    <% rs3.MoveNext %>
                <% Loop %>
            </ul>
            <% rs4.MoveFirst %>
            <ul class="comment-list" id="trend">
                <% Do While Not rs4.EOF %>
                    <li class="comment-word" onclick="commentPush(<%= i %>, this)"><span><%= rs4.Fields("comment").Value %></span></li>    
                    <% rs4.MoveNext %>
                <% Loop %>
            </ul>
            <% rs5.MoveFirst %>
            <ul class="comment-list" id="history">
                <% Do While Not rs5.EOF %>
                    <li class="comment-word" onclick="commentPush(<%= i %>, this)"><span><%= rs5.Fields("comment").Value %></span></li>    
                    <% rs5.MoveNext %>
                <% Loop %>
            </ul>
        </div>
        <div class="dummy-box" id="dummy">
        </div>
        <div class="commit-container">
            <span class="commit" onclick="modalCommit()">決定</span>
        </div>
    </div>         

    <main>
        <form class="tasting" action="tasting_merge.asp" method="post" name="my-form">
            <ul>
                <% i = 1 %>
                <% Do While Not rs.EOF %>
                    <li>
                        <div class="item">
                            <div class="item-info"> 
                                <input type="hidden" name="tasting-id<%= i %>" value="<%= rs.Fields("tasting_id").value %>">
                                <input type="hidden" class="sample-id" id="sample-id<%= i %>" name="sample-id<%= i %>" value="<%= rs.Fields("sample_id").value %>">
                                <span>ID:<%= rs.Fields("sample_id").value %></span>
                                <span>工程:<%= rs.Fields("process_text").value %></span>
                                <span>品目:<%= rs.Fields("material_text").value %></span>
                                <span>Lot:<%= rs.Fields("lot").value %></span>
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
                                <span class="plus" id="plus<%= i %>" onclick="modalShow(<%= i %>)"><img src="../icon/plus.png" alt="+" height="20" width="20"></span>
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
    <footer>
        <div class="footer-message">
            歩きスマホは絶対にやめましょう。
        </div>
    </footer>
    <script src="../js/modal.js"></script>
</body>
</html>