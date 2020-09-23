Attribute VB_Name = "Module1"
'Author£ºWXJ_Lake
'Email: webmaster@archtide.com
'Homepage£ºwww.archtide.com
'I borrowed this module code from this guy, its great :)

Option Explicit

Public Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Public Declare Function SetWindowRgn Lib "user32" (ByVal hwnd As Long, ByVal hRgn As Long, ByVal bRedraw As Boolean) As Long
Public Declare Function CreateRectRgn Lib "gdi32" (ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long) As Long
Public Declare Function CombineRgn Lib "gdi32" (ByVal hDestRgn As Long, ByVal hSrcRgn1 As Long, ByVal hSrcRgn2 As Long, ByVal nCombineMode As Long) As Long
Public Const RGN_OR = 2


Private Type SAFEARRAYBOUND
    cElements As Long
    lLbound As Long
End Type
Private Type SAFEARRAY2D
    cDims As Integer
    fFeatures As Integer
    cbElements As Long
    cLocks As Long
    pvData As Long
    Bounds(0 To 1) As SAFEARRAYBOUND
End Type

Private Declare Function VarPtrArray Lib "msvbvm60.dll" Alias "VarPtr" (Ptr() As Any) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (lpvDest As Any, lpvSource As Any, ByVal cbCopy As Long)

Public Declare Function ReleaseCapture Lib "user32" () As Long
Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Public Const HTCAPTION = 2
Public Const WM_NCLBUTTONDOWN = &HA1

'for translucent effect in win2k, remove this if run in win9x or NT
Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Public Declare Function SetLayeredWindowAttributes Lib "user32" (ByVal hwnd As Long, ByVal crKey As Long, ByVal bAlpha As Byte, ByVal dwFlags As Long) As Long
Public Const WS_EX_LAYERED = &H80000
Public Const GWL_EXSTYLE = (-20)
Public Const LWA_ALPHA = &H2
Public Const LWA_COLORKEY = &H1

Public Sub SetAutoRgn(hForm As Form, Optional transColor As Long = vbNull)
  Dim X As Long, Y As Long
  Dim Rgn1 As Long, Rgn2 As Long
  Dim SPos As Long, EPos As Long
  Dim Wid As Long, Hgt As Long
  Dim xoff As Long, yoff As Long
  Dim DIB As New cDIBSection
  Dim bDib() As Byte
  Dim tSA As SAFEARRAY2D
  
  
    'get the picture size of the form
  DIB.CreateFromPicture hForm.Picture
  Wid = DIB.Width
  Hgt = DIB.Height
  
  With hForm
    .ScaleMode = vbPixels
    'compute the title bar's offset
    xoff = (.ScaleX(.Width, vbTwips, vbPixels) - .ScaleWidth) / 2
    yoff = .ScaleY(.Height, vbTwips, vbPixels) - .ScaleHeight - xoff
    'change the form size
    .Width = (Wid + xoff * 2) * Screen.TwipsPerPixelX
    .Height = (Hgt + xoff + yoff) * Screen.TwipsPerPixelY
  End With
  
  ' have the local matrix point to bitmap pixels
    With tSA
        .cbElements = 1
        .cDims = 2
        .Bounds(0).lLbound = 0
        .Bounds(0).cElements = DIB.Height
        .Bounds(1).lLbound = 0
        .Bounds(1).cElements = DIB.BytesPerScanLine
        .pvData = DIB.DIBSectionBitsPtr
    End With
    CopyMemory ByVal VarPtrArray(bDib), VarPtr(tSA), 4
        
      
' if there is no transColor specified, use the first pixel as the transparent color
  If transColor = vbNull Then transColor = RGB(bDib(0, 0), bDib(1, 0), bDib(2, 0))
  
  Rgn1 = CreateRectRgn(0, 0, 0, 0)
  
  For Y = 0 To Hgt - 1 'line scan
    X = -3
    Do
     X = X + 3
     
     While RGB(bDib(X, Y), bDib(X + 1, Y), bDib(X + 2, Y)) = transColor And (X < Wid * 3 - 3)
       X = X + 3 'skip the transparent point
     Wend
     SPos = X / 3
     While RGB(bDib(X, Y), bDib(X + 1, Y), bDib(X + 2, Y)) <> transColor And (X < Wid * 3 - 3)
       X = X + 3 'skip the nontransparent point
     Wend
     EPos = X / 3
     
     'combine the region
     If SPos <= EPos Then
         Rgn2 = CreateRectRgn(SPos + xoff, Hgt - Y + yoff, EPos + xoff, Hgt - 1 - Y + yoff)
         CombineRgn Rgn1, Rgn1, Rgn2, RGN_OR
         DeleteObject Rgn2
     End If
    Loop Until X >= Wid * 3 - 3
  Next Y
  
  SetWindowRgn hForm.hwnd, Rgn1, True  'set the final shap region
  DeleteObject Rgn1
 
End Sub
