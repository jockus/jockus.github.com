
;;; Happy hacking
#InstallKeybdHook
LControl::
Send, {LControl Down}
KeyWait, LControl
Send, {LControl Up}
if ( A_PriorKey = "LControl" )
{
	Send, {Esc}
}
return

;;;; Volume
#,::Volume_Down
#.::Volume_Up
#/::Volume_Mute
#/::Send {Media_Play_Pause}
`::Reload
!3::£


;;; Normal
;;; SetCapsLockState AlwaysOff
;;; #InstallKeybdHook
;;; Capslock::
;;; Send, {LControl Down}
;;; KeyWait, CapsLock
;;; Send, {LControl Up}
;;; if ( A_PriorKey = "CapsLock" )
;;; {
;;; 	Send, {Esc}
;;; }
;;; 
;;; return
;;; 
;;; ¬::Reload
;;; CapsLock::LControl
;;; +CapsLock::+LControl
;;; !CapsLock::!LControl
;;; @::"
;;; "::@
;;; 
;;; ;;;; Volume
;;; #,::Volume_Down
;;; #.::Volume_Up
;;; ; #/::Volume_Mute
;;; #/::Send {Media_Play_Pause}
