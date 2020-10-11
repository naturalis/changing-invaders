Imports System.IO
Imports System.Net
Imports System.Collections.Generic
Module ontologicalargumentparser
    Dim recievedMessage As Integer = 0
    Dim sendMessage As Integer = 0
    Dim sessionID As String = ""
    Dim busyWithDebugging As Boolean = False
    Dim inputLocation As String
    Dim outputLocation As String
    Dim organism As String = 154
    Dim numberOfSignifcant As Integer = 30
    Sub Send(towards As WebSockets.ClientWebSocket, data As String)
        towards.SendAsync(New ArraySegment(Of Byte)(Text.Encoding.UTF8.GetBytes(data)), WebSockets.WebSocketMessageType.Text, True, Nothing).Wait()
    End Sub
    Sub OverSend(towards As WebSockets.ClientWebSocket, data As String)
        towards.SendAsync(New ArraySegment(Of Byte)(Text.Encoding.UTF8.GetBytes("[""" & sendMessage.ToString & "#0|" & data & """]")), WebSockets.WebSocketMessageType.Text, True, Nothing).Wait()
        sendMessage += 1
    End Sub
    Function Recieve(from As WebSockets.ClientWebSocket) As String
        Dim bytes(650000) As Byte
        Dim answer As String
        Dim answ As ArraySegment(Of Byte) = New ArraySegment(Of Byte)(bytes)
        from.ReceiveAsync(answ, Nothing).Wait()
        answer = Text.Encoding.UTF8.GetString(answ.Array, 0, answ.Count).Replace(vbNullChar, String.Empty)
        recievedMessage += 1
        Return answer
    End Function
    Sub ErrorOut(errorValue As String)
        Console.Error.WriteLine(errorValue)
        Environment.Exit(2)
    End Sub
    
    
    Sub ParseArguments(args As String())
        Dim arguments As New List(Of String)(args)
        Dim argumentsNeeded As Boolean
        Dim freearguments As Integer = 0
        Dim firstArgument As String
        Dim organismFound As Boolean = False
        While arguments.Count > 0
            firstArgument = arguments(0)
            If firstArgument.StartsWith("--") Then
                If firstArgument = "--amount" Then
                    If arguments.Count > 1 Then
                        numberOfSignifcant = Convert.ToInt32(arguments(1))
                        arguments.RemoveAt(0) : arguments.RemoveAt(0)
                    Else : ErrorOut("There is here no argument that describes the number of terms at max.") : End If
                ElseIf firstArgument = "--organism" Then
                    If arguments.Count > 1 Then
                        organism = arguments(1)
                        arguments.RemoveAt(0) : arguments.RemoveAt(0)
                    Else : ErrorOut("There is no argument that describes the organism.") : End If
                Else : ErrorOut("There is invoked an option that is not understood correctly: " & firstArgument)
                End If
            ElseIf firstArgument.StartsWith("-") Then
                argumentsNeeded = False
                For Each character In firstArgument.Substring(1)
                    If character = "n" Then
                        If argumentsNeeded Then ErrorOut("Multiple options for an argument")
                        If arguments.Count > 1 Then
                            numberOfSignifcant = arguments(1)
                            arguments.RemoveAt(1)
                            argumentsNeeded = True
                        Else : ErrorOut("There is here no argument that describes the number of terms at max.") : End If
                    ElseIf character = "o" Then
                        If argumentsNeeded Then ErrorOut("Multiple options for an argument")
                        If arguments.Count > 1 Then
                            organism = arguments(1)
                            arguments.RemoveAt(1)
                            argumentsNeeded = True
                        Else : ErrorOut("There is no argument that describes the organism.") : End If
                    Else : ErrorOut("There is invoked an option that is not understood correctly: -" & character)
                    End If
                Next
                arguments.RemoveAt(0)
            Else
                Select Case freearguments
                    Case 0
                        If Not firstArgument = "-" Then inputLocation = firstArgument
                    Case 1
                        outputLocation = firstArgument
                    Case Else
                End Select
                arguments.RemoveAt(0)
            End If
        End While
        If Not Integer.TryParse(organism, New Integer) Then
            If File.Exists("possible.organisms") Then
                For Each potentialOrganism In File.ReadAllLines("possible.organisms")
                    Console.Write(potentialOrganism.Split("->")(1))
                    If potentialOrganism.Split("->")(0).ToLower = organism Then
                        organism = potentialOrganism.Split("->")(1)
                        organismFound = True
                        Exit For
                    End If
                Next
                If Not organismFound Then ErrorOut("Organism not found in table, check spelling.")
            Else : Console.Error.WriteLine("Cannot lookup for the organism, trust that it will be alright.")
            End If
        End If
        If IsNothing(outputLocation) AndAlso Not IsNothing(inputLocation) Then outputLocation = inputLocation & ".oap"
    End Sub
    Sub WaitUntilSomethingInMessage(connection As WebSockets.ClientWebSocket, something As String)
        Dim oneShouldContinue As Boolean = True, answer As String, i As Integer = 0
        While oneShouldContinue
            answer = Recieve(from:=connection)
            If busyWithDebugging Then Console.WriteLine("answer (" & i & ") (waiting for " & something & "):" + answer)
            If answer.Split("|m|").Length > 1 Then
                If answer.Contains("errors") Then
                    Send(towards:=connection, data:="[""ACK " & (CInt("&H" & (answer.Split("#")(0).Split("""")(1))) + 1).ToString & """]")
                End If
                If answer.Contains(something) Then oneShouldContinue = False
                If answer.Contains("The application unexpectedly exited.") Then
                    Console.Error.WriteLine("Error occured on ShinyGO, check your input or report a bug.")
                    Environment.Exit(2)
                End If
            End If
            i += 1
        End While
    End Sub
    Function readSTDIN() As String
        Dim line As String = Console.ReadLine(), complete As String = "", first As Boolean = True
        While Not line Is Nothing
            If first Then : complete &= line : first = False : Else : complete &= vbLf & line : End If
            line = Console.ReadLine()
        End While
        Return complete
    End Function
    Sub Main(args As String())
        Dim initString As String = GenInit(), input As String
        ParseArguments(args)
        ' making sure that any line ending will parse correctly
        If IsNothing(inputLocation) Then input = readSTDIN() Else input = File.ReadAllText(inputLocation).Replace(vbCrLf, vbLf).Replace(vbCr, vbLf)
        Dim wc = New Net.WebClient()
        wc.DownloadData("http://bioinformatics.sdstate.edu/go/")
        Dim shinyGO = New WebSockets.ClientWebSocket()
        Dim cookie As String = wc.ResponseHeaders(HttpResponseHeader.SetCookie).Split(";")(0)
        shinyGO.Options.SetRequestHeader("Cookie", cookie)
        shinyGO.Options.KeepAliveInterval = New TimeSpan(10000)
        ' The server is http (not secure) anyway
        ServicePointManager.ServerCertificateValidationCallback = Function (s, c, h, d) True
        shinyGO.ConnectAsync(New Uri("ws://bioinformatics.sdstate.edu/go/__sockjs__/" & initString & "/websocket"), Nothing).Wait()
        If (shinyGO.State = WebSockets.WebSocketState.Open) Then
            Dim answer As String
            Recieve(from:=shinyGO)
            OverSend(towards:=shinyGO, data:="o|")
            OverSend(towards:=shinyGO, data:="m|{\""method\"":\""init\"",\""data\"":{\""ModalExamplePPI\"":false,\""InteractiveNetwork\"":false,\""useDemo:shiny.action\"":0,\""goButton:shiny.action\"":0,\""layoutButton:shiny.action\"":0,\""GONetwork:shiny.action\"":0,\""ModalPPI:shiny.action\"":0,\""layoutButtonStatic:shiny.action\"":0,\""radio\"":\""300\"",\""selectOrg\"":[\""" & organism & "\""],\""maxTerms\"":\""" & numberOfSignifcant.ToString & "\"",\""speciesName\"":[],\""STRINGdbGO\"":\""Process\"",\""nGenesPPI\"":50,\""wrapTextNetwork\"":false,\""wrapTextNetworkStatic\"":false,\""minFDR:shiny.number\"":0.05,\""edgeCutoff:shiny.number\"":0.2,\""input_text\"":\""" & input.Replace(vbLf, "\\n") & "\"",\"".clientdata_output_KeggImage_width\"":625,\"".clientdata_output_KeggImage_height\"":0,\"".clientdata_output_selectGO1_hidden\"":false,\"".clientdata_output_species_hidden\"":false,\"".clientdata_output_EnrichmentTable_hidden\"":false,\"".clientdata_output_downloadEnrichment_hidden\"":true,\"".clientdata_output_listSigPathways_hidden\"":true,\"".clientdata_output_KeggImage_hidden\"":true,\"".clientdata_output_GOTermsTree4Download_hidden\"":true,\"".clientdata_output_GOTermsTree_hidden\"":true,\"".clientdata_output_enrichmentNetworkPlotInteractive_hidden\"":true,\"".clientdata_output_enrichmentNetworkPlotInteractiveDownload_hidden\"":true,\"".clientdata_output_downloadEdges_hidden\"":true,\"".clientdata_output_downloadNodes_hidden\"":true,\"".clientdata_output_conversionTable_hidden\"":true,\"".clientdata_output_downloadGeneInfo_hidden\"":true,\"".clientdata_output_grouping_hidden\"":true,\"".clientdata_output_downloadGrouping_hidden\"":true,\"".clientdata_output_genePlot_hidden\"":true,\"".clientdata_output_genePlot2_hidden\"":true,\"".clientdata_output_genomePlot_hidden\"":true,\"".clientdata_output_promoter_hidden\"":true,\"".clientdata_output_downloadPromoter_hidden\"":true,\"".clientdata_output_STRINGDB_species_stat_hidden\"":true,\"".clientdata_output_STRINGDB_mapping_stat_hidden\"":true,\"".clientdata_output_STRING_enrichmentDownload_hidden\"":true,\"".clientdata_output_stringDB_GO_enrichment_hidden\"":true,\"".clientdata_output_stringDB_network_link_hidden\"":true,\"".clientdata_output_stringDB_network1_hidden\"":true,\"".clientdata_output_enrichmentNetworkPlotDownload_hidden\"":true,\"".clientdata_output_enrichmentNetworkPlot_hidden\"":true,\"".clientdata_pixelratio\"":1,\"".clientdata_url_protocol\"":\""http:\"",\"".clientdata_url_hostname\"":\""bioinformatics.sdstate.edu\"",\"".clientdata_url_port\"":\""\"",\"".clientdata_url_pathname\"":\""/go/\"",\"".clientdata_url_search\"":\""\"",\"".clientdata_url_hash_initial\"":\""\"",\"".clientdata_url_hash\"":\""\"",\"".clientdata_singletons\"":\""\"",\"".clientdata_allowDataUriScheme\"":true}}")
            answer = Recieve(from:=shinyGO)
            If answer.Split("|m|").Length = 1 Then answer = Recieve(from:=shinyGO)
            sessionID = Array.Find(Of String)(answer.Split("|m|")(1).Split(New Char() {",", "{", "}"}), Function(x) x.Contains("sessionId")).Split("\""").Reverse()(1)
            WaitUntilSomethingInMessage(shinyGO, something:="busy\"":\""idle")
            OverSend(towards:=shinyGO, data:="m|{\""method\"":\""update\"",\""data\"":{\""selectOrg\"":[\""154\""]}}")
            If busyWithDebugging Then Console.Error.WriteLine("RET2:" + Recieve(from:=shinyGO))
            OverSend(towards:=shinyGO, data:="m|{\""method\"":\""update\"",\""data\"":{\""selectGO\"":\""GOBP\""}}")
            OverSend(towards:=shinyGO, data:="m|{\""method\"":\""update\"",\""data\"":{\""goButton:shiny.action\"":1}}")
            If busyWithDebugging Then Console.WriteLine(Recieve(from:=shinyGO))
            OverSend(towards:=shinyGO, data:="m|{\""method\"":\""update\"",\""data\"":{\"".clientdata_output_downloadEnrichment_hidden\"":false}}")
            ' OverSend(towards:=shinyGO, data:="m|{\""method\"":\""update\"",\""data\"":{\"".clientdata_output_downloadEnrichment_hidden\"":false}}")
            WaitUntilSomethingInMessage(shinyGO, something:="<td>")
            wc.Headers.Add(HttpRequestHeader.Cookie, cookie)
            Dim output As String = wc.DownloadString("http://bioinformatics.sdstate.edu/go/session/" & sessionID & "/download/downloadEnrichment?w=")
            If IsNothing(outputLocation) Then Console.WriteLine(output) Else File.WriteAllText(outputLocation, output)
        Else : Console.WriteLine("No connection Error (is your device connected to the internet?)")
        End If
    End Sub

    Function GenRandom(start As String, until As Integer, range As Integer(), notReally As Integer()) As String
        ' generate a random string, using a range, excluding the characters in not really
        While start.Length < until
            Threading.Thread.Sleep(200 + New Random().Next(0, 50))
            Dim b As Byte = New Random().Next(range(0), range(1))
            If Not notReally.Contains(b) Then start &= Chr(b)
        End While
        Return start
    End Function

    Function GenInit() As String
        Dim initString As String = GenRandom("n=", 20, New Integer() {65, 122}, {37, 40, 41, 43, 91, 92, 93, 94, 96, 123, 125}) & "/"
        initString = GenRandom(initString, 24, {48, 57}, {}) & "/"
        Return GenRandom(initString, 33, {65, 122}, {37, 40, 41, 43, 91, 92, 93, 94, 96, 123, 125})
    End Function
End Module
