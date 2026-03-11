Class {
	#name : 'VoiceAssistant',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#category : 'VoicePharo',
	#package : 'VoicePharo'
}

{ #category : 'core' }
VoiceAssistant >> clearHistory [
    history removeAll.
    UIManager default inform: 'History cleared'.
]

{ #category : 'core' }
VoiceAssistant >> evaluateExpression: expression [

    | workspace |
    
    workspace := StPlaygroundPresenter open.
    workspace interactionModel doItReceiver: nil.
    workspace text: expression.
    
    UIManager default inform: 'Expression opened in Playground. Use Print it to see the result.'.
]

{ #category : 'core' }
VoiceAssistant >> execute: command [

    | text matched |

    history add: command.

    text := command asLowercase.
    matched := false.
    
    (text includesSubstring: 'open class')
        ifTrue: [
            | name |
             name := command copyAfterLast: Character space.
             self openClass: name.
             matched := true
     ].
     
    (text includesSubstring: 'find method')
    ifTrue: [
        | parts selector |
        
        parts := command substrings.
        selector := parts last.

        self findMethod: selector.
        matched := true
    ].

    (text includesSubstring: 'evaluate')
        ifTrue: [
            | expr |
            expr := command copyAfter: 'evaluate '.
            self evaluateExpression: expr.
            matched := true
    ].

    (text includesSubstring: 'help')
        ifTrue: [ 
	        self showHelp.
	        matched := true 
	 ].
    
    (text includesSubstring: 'hello')
        ifTrue: [
            self sayHello.
            matched := true
        ].

    (text includesSubstring: 'browser')
        ifTrue: [
            self openBrowser.
            matched := true
        ].

    (text includesSubstring: 'workspace')
        ifTrue: [
            self openWorkspace.
            matched := true
        ].
    
    (text includesSubstring: 'time')
       ifTrue: [ 
	       self showTime.
	       matched := true
	 ].

    (text includesSubstring: 'history')
        ifTrue: [
            self showHistory.
            matched := true
        ].

   (text includesSubstring: 'clear history')
       ifTrue: [ 
	       self clearHistory .
	       matched :=true
	 ].

    matched
        ifTrue: [ self playNotificationSound ]
        ifFalse: [ self suggestCommandFor: text ].
]

{ #category : 'core' }
VoiceAssistant >> findMethod: selectorName [

    | selector |

    selector := selectorName trimBoth asSymbol.

    SystemNavigation default browseAllImplementorsOf: selector.
]

{ #category : 'core' }
VoiceAssistant >> greet [
    Transcript show: 'Voice assistant ready'; cr.
]

{ #category : 'initialization' }
VoiceAssistant >> initialize [
    super initialize.
    history := OrderedCollection new.
]

{ #category : 'core' }
VoiceAssistant >> knownCommands [
    ^ #('hello' 'open browser' 'open workspace' 'show history')
]

{ #category : 'core' }
VoiceAssistant >> listen [
    | command |
    command := UIManager default request: 'Enter a command:'.
    command ifNotNil: [ self execute: command ].
]

{ #category : 'core' }
VoiceAssistant >> openAssistantWindow [

    | command |

    [ 
        command := UIManager default request: 'Voice Assistant Command (type exit to stop):'.
        command ifNil: [ ^self ].

        command asLowercase = 'exit'
            ifTrue: [ ^self ].

        self execute: command.
    ] repeat.
]

{ #category : 'core' }
VoiceAssistant >> openBrowser [
    Smalltalk tools browser open.
]

{ #category : 'core' }
VoiceAssistant >> openClass: className [

    | cls |

    cls := Smalltalk at: className asSymbol ifAbsent: [ nil ].

    cls ifNil: [
        UIManager default inform: 'Class not found'
    ] ifNotNil: [
        cls browse
    ].
]

{ #category : 'core' }
VoiceAssistant >> openWorkspace [
    (Smalltalk tools workspace) open.
]

{ #category : 'core' }
VoiceAssistant >> playNotificationSound [
    Transcript show: '🔔 Command executed'; cr.
]

{ #category : 'core' }
VoiceAssistant >> sayHello [
    Transcript show: 'Hello! I am your Pharo voice assistant.'; cr.

]

{ #category : 'core' }
VoiceAssistant >> showHelp [
    UIManager default inform:
'Available commands:

hello
open browser
open workspace
show history
help
'.
]

{ #category : 'core' }
VoiceAssistant >> showHistory [
    history inspect.
]

{ #category : 'core' }
VoiceAssistant >> showTime [
    UIManager default inform: 'Current time: ', Time now printString.
]

{ #category : 'core' }
VoiceAssistant >> suggestCommandFor: text [

    | suggestion |

    suggestion := self knownCommands
        detect: [:cmd | text includesSubstring: (cmd copyUpTo: Character space)]
        ifNone: [ nil ].

    suggestion ifNil: [
        UIManager default inform: 'Unknown command'
    ] ifNotNil: [
        UIManager default inform: 'Did you mean: ', suggestion
    ].
]
