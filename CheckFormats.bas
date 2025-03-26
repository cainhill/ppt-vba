' Last Updated: March 25, 2025
' Author: Cain Hill
' Purpose: Use this script to find and fix slide formatting issues
' Slide Format Goals:
'   1. Text links must be underlined and coloured either blue or red
'   2. Text highlights must be yellow
'   3. Slides must only use this colour set: red, blue, greyscale, pink
' This Script:
'   1. Sets all text hyperlinks to underlined
'   2. Sets all text hyperlinks to blue (#0000ff), if not already red (#ff0000)
'   3. Sets all text highlights to use yellow (#ffff00)
'   4. Sets all text/fill/border colours to pink, if not already greyscale (saturation = 0)
' 


Sub CheckFormats()
    Dim slide As slide
    For Each slide In ActivePresentation.Slides
      LoopShapes(slide)
    Next slide
End Sub

Sub LoopShapes(slide As slide)
    Dim shape As shape
    For Each shape In slide.Shapes
        If shape.HasTextFrame Then
            If shape.TextFrame.HasText Then
                HandleText(shape)
            End If
        End If
        ' TODO: Image
        ' TODO: Table
    Next shape
End Sub

Sub HandleText(shape as shape)

    Dim textRange As textRange: Set shape.TextFrame.TextRange
    Dim fontColour As Long
    Dim i As Integer
    Dim run As TextRange

    For i = 1 To textRange.Hyperlinks.Count
        textRange.Hyperlinks(i).TextRange.Font.Underline = True
        If textRange.Hyperlinks(i).TextRange.Font.Color <> RGB(255, 0, 0) Then
            textRange.Hyperlinks(i).TextRange.Font.Color = RGB(0, 0, 255)
        End If
    Next i

    For i = 1 To textRange.Runs.Count
        Set run = textRange.Runs(i)
        If run.HighlightColor.RGB <> RGB(255, 255, 0) Then
            run.HighlightColor.RGB = RGB(255, 255, 0)
        End If
        If Not IsValidColor(run.Font.Color) Then
            run.Font.Color = RGB(255, 20, 147)
        End If
    Next i

End Sub

' Returns true if colour is greyscale, red, blue, or pink
Function IsValidColour(colour As Long) As Boolean
    IsValidColour = IsGreyscale(Colour) Or (colour = RGB(255, 0, 0)) Or (colour = RGB(0, 0, 255)) Or (colour = RGB(255, 20, 147))
End Function

' Returns true if colour is greyscale
Function IsGrayscale(Colour As Long) As Boolean
    Dim R As Integer: R = Colour Mod 256
    Dim G As Integer: G = (Colour \ 256) Mod 256 
    Dim B As Integer: B = (Colour \ 65536) Mod 256
    IsGrayscale = (R = G) And (G = B)
End Function


Sub FormatAndCheckColors()
    Dim slide As slide
    Dim shape As shape
    Dim textRange As textRange
    Dim fontColor As Long
    Dim fillColor As Long
    Dim borderColor As Long
    Dim tableFillColor As Long
    Dim tableBorderColor As Long
    Dim pictureBorderColor As Long
    Dim nonCompliantCount As Integer
    nonCompliantCount = 0

            ' Check fill color
            If shape.Fill.Type = msoFillSolid Then
                fillColor = shape.Fill.ForeColor.RGB
                If Not IsValidColor(fillColor) Then
                    shape.Fill.ForeColor.RGB = RGB(255, 20, 147) ' Pink (#FF1493)
                    nonCompliantCount = nonCompliantCount + 1
                End If
            End If

            ' Check border color for shapes
            If shape.Line.Visible = msoTrue Then
                borderColor = shape.Line.ForeColor.RGB
                If Not IsValidColor(borderColor) Then
                    shape.Line.ForeColor.RGB = RGB(255, 20, 147) ' Pink (#FF1493)
                    nonCompliantCount = nonCompliantCount + 1
                End If
            End If

            ' Check table fill color
            If shape.HasTable Then
                For Each row In shape.Table.Rows
                    For Each cell In row.Cells
                        tableFillColor = cell.Shape.Fill.ForeColor.RGB
                        If Not IsValidColor(tableFillColor) Then
                            cell.Shape.Fill.ForeColor.RGB = RGB(255, 20, 147) ' Pink (#FF1493)
                            nonCompliantCount = nonCompliantCount + 1
                        End If
                    Next cell
                Next row

                ' Check table border color
                For Each row In shape.Table.Rows
                    For Each cell In row.Cells
                        tableBorderColor = cell.Shape.Line.ForeColor.RGB
                        If Not IsValidColor(tableBorderColor) Then
                            cell.Shape.Line.ForeColor.RGB = RGB(255, 20, 147) ' Pink (#FF1493)
                            nonCompliantCount = nonCompliantCount + 1
                        End If
                    Next cell
                Next row
            End If

            ' Check picture border color
            If shape.Type = msoPicture Then
                pictureBorderColor = shape.Line.ForeColor.RGB
                If Not IsValidColor(pictureBorderColor) Then
                    shape.Line.ForeColor.RGB = RGB(255, 20, 147) ' Pink (#FF1493)
                    nonCompliantCount = nonCompliantCount + 1
                End If
            End If
        Next shape

        ' STEP 3: Add or remove the red "ISSUE" box in the top left corner based on non-compliant colors
        If nonCompliantCount > 0 Then
            ' Check if there is already an "ISSUE" box
            If Not IsIssueBoxPresent(slide) Then
                ' Create a red box in the top left corner with the text "ISSUE"
                CreateIssueBox slide
            End If
        Else
            ' If no non-compliant colors are found, delete the "ISSUE" box if it exists
            If IsIssueBoxPresent(slide) Then
                DeleteIssueBox slide
            End If
        End If
    Next slide
End Sub

' Function to check if the color is valid (red, blue, pink, or grayscale)
Function IsValidColor(color As Long) As Boolean
    ' Valid colors are: red (#FF0000), blue (#0000FF), pink (#FF1493), or grayscale (saturation = 0)
    Dim hsl As Variant
    hsl = RGBToHSL(color)
    
    If color = RGB(255, 0, 0) Or color = RGB(0, 0, 255) Or color = RGB(255, 20, 147) Then
        IsValidColor = True ' Red, Blue, or Pink are allowed
    ElseIf hsl(2) = 0 Then
        IsValidColor = True ' Grayscale colors are allowed (saturation = 0)
    Else
        IsValidColor = False ' Non-compliant colors
    End If
End Function
