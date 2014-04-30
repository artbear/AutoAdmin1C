Wscript.Quit( main() )

'********************************************************************
' Возвращает 1 при успехе, 0 - при неудаче
Function main( )
    
  'Make sure the host is csript, if not then abort
  VerifyHostIsCscript()
  
' проверить версию Windows Script Host
  if CDbl(replace(WScript.Version,".",","))<5.6 then
    WScript.Echo "Для работы сценария требуется Windows Script Host версии 5.6 и выше !"
    Exit Function
  end if  

  SqlSrvConnect()

End Function

Sub SqlSrvConnect()
	Dim conn
	Set conn = CreateObject("ADODB.Connection")
	With conn
	   		.ConnectionString = "Provider=SQLOLEDB;Persist Security Info=False;User Id=mylogin;Password=mypass;Initial Catalog=MY_PILOT;Data Source=MyServer\MyTestBase"
	      	.Open 
	      	'WScript.Echo "Opened"
	End With

	If conn.State = 1 Then
		TextQuery ="EXECUTE AS LOGIN = 'MyDomain\my.mail.services';exec msdb.dbo.sp_send_dbmail @profile_name = 'my.mail.service ',@recipients = 'test@mydomain.ru',@copy_recipients = 'test@mydomain.ru',@from_address = 'all.my.support@domain.ru',@reply_to = 'all.my.support@domain.ru',@subject = 'Тема',@body = 'testbody'"  	
		conn.Execute(TextQuery)
		'If conn.Errors.Count > 0 Then
		'	WScript.Echo GetErrorStringFromConnection("2222222" & conn.Errors)		
		'End If
	'Else
		'WScript.Echo GetErrorStringFromConnection("11111111" & conn.Errors)
	End If

	conn.Close
	Set conn = Nothing

End Sub 'SqlSrvConnect

Function GetErrorStringFromConnection(Errors)
	ErrorString = ""
	For Each errLoop In Errors	
		ErrorString = ErrorString & errLoop.Description & vbCRLF
	Next
	GetErrorStringFromConnection = ErrorString
End Function 'GetErrorStringFromConnection

'********************************************************************
'*
'* Sub      VerifyHostIsCscript()
'*
'* Purpose: Determines which program is used to run this script.
'*
'* Input:   None
'*
'* Output:  If host is not cscript, then an error message is printed 
'*          and the script is aborted.
'*
'********************************************************************
Sub VerifyHostIsCscript()

    ON ERROR RESUME NEXT

    'Define constants
    CONST CONST_ERROR                   = 0
    CONST CONST_WSCRIPT                 = 1
    CONST CONST_CSCRIPT                 = 2
    
    Dim strFullName, strCommand, i, j, intStatus

    strFullName = WScript.FullName

    If Err.Number then
        Call Echo( "Error 0x" & CStr(Hex(Err.Number)) & " occurred." )
        If Err.Description <> "" Then
            Call Echo( "Error description: " & Err.Description & "." )
        End If
        intStatus =  CONST_ERROR
    End If

    i = InStr(1, strFullName, ".exe", 1)
    If i = 0 Then
        intStatus =  CONST_ERROR
    Else
        j = InStrRev(strFullName, "\", i, 1)
        If j = 0 Then
            intStatus =  CONST_ERROR
        Else
            strCommand = Mid(strFullName, j+1, i-j-1)
            Select Case LCase(strCommand)
                Case "cscript"
                    intStatus = CONST_CSCRIPT
                Case "wscript"
                    intStatus = CONST_WSCRIPT
                Case Else       'should never happen
                    Call Echo( "An unexpected program was used to " _
                                       & "run this script." )
                    Call Echo( "Only CScript.Exe or WScript.Exe can " _
                                       & "be used to run this script." )
                    intStatus = CONST_ERROR
                End Select
        End If
    End If

    If intStatus <> CONST_CSCRIPT Then
        Call Echo( "Please run this script using CScript." & vbCRLF & _
             "This can be achieved by" & vbCRLF & _
             "1. Using ""CScript SystemAccount.vbs arguments"" for Windows 95/98 or" _
             & vbCRLF & "2. Changing the default Windows Scripting Host " _
             & "setting to CScript" & vbCRLF & "    using ""CScript " _
             & "//H:CScript //S"" and running the script using" & vbCRLF & _
             "    ""SystemAccount.vbs arguments"" for Windows NT/2000/XP." )
        WScript.Quit(0)
    End If
End Sub 'VerifyHostIsCscript