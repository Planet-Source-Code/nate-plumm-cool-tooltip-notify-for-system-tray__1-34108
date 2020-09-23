VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2175
   ClientLeft      =   12825
   ClientTop       =   9390
   ClientWidth     =   3180
   LinkTopic       =   "Form1"
   Picture         =   "Form1.frx":0000
   ScaleHeight     =   2175
   ScaleWidth      =   3180
   ShowInTaskbar   =   0   'False
   Begin VB.Timer Timer1 
      Interval        =   3000
      Left            =   960
      Top             =   840
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "You've got herpes!"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   360
      TabIndex        =   0
      Top             =   840
      Width           =   2535
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function SetWindowPos& Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long)
Private Sub Form_Load()
Dim t As Single
Dim rtn As Long
rtn = SetWindowPos(Form1.hwnd, -1, 0, 0, 0, 0, 3)
Me.Left = Screen.Width - Me.Width
Me.Top = Screen.Height - Me.Height - 800
t = Timer

If Me.Picture <> 0 Then
  Call SetAutoRgn(Me)
End If
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = vbLeftButton Then
  ReleaseCapture
  SendMessage Me.hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0&
End If
End Sub

Private Sub Label1_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = vbLeftButton Then
  ReleaseCapture
  SendMessage Me.hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0&
End If
End Sub

Private Sub Timer1_Timer()
If Form1.Visible = True Then Form1.Visible = False Else Form1.Visible = True
End Sub
