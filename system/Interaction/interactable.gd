extends Area3D

class_name Interactable

# Emitted when an Interactor start looking at me
signal focused(interactor: Interactor)
# Emitted when an Interactor stops looking at me
signal unfocused(interactor: Interactor)
# Emitted when an Interactor Interact with me
signal interacted(interactor: Interactor)
