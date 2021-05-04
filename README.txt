# Label Scaling Issue
 A simple project which demonstrates a label scaling issue in Godot

Steps to reproduce the issue:
-----------------------------

1. Run the TitleScreen scene (the only scene)
2. Press space-bar to proceed to the file select menu; notice that the first label ("save file 1") is scaled compared to the other labels, even though the initial scaling in the inspector is Vector2(1,1). 
   This means scaling has successfully been achieved through code (focus_cursor function).
3. Navigate up and down the save file select menu with the arrow keys to scale the other selections (again using the focus_cursor function).
4. Press space-bar again to proceed to the confirmation menu; notice that this time the "Cancel" label has not been scaled, despite the exact same code (focus_cursor) having been called, in a pretty 
   much identical situation.
5. Pressing left or right will cause the selected choice to scale (using the focus_cursor function).

Issues:
-----------------------------

1. The behavior when transitioning to the Save File Select menu vs the Confirmation menu seems to be inconsistent. 
2. The behavior when navigating left and right on the Confirmation menu compared to transitioning to the Confirmation menu seem to be inconsistent as well (they both employ focus_cursor, but only one 
   actually works).

