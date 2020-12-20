# Modular Component System
*Created by Mullets_Gavin*

Modular Component System, otherwise known as MCS, is a component based solution to Roblox UI which allows you to modularly create components & handle all code within a nice environment.

## MCS Documentation
This is the recommended way to initialize a component on a given tag:

```lua
MCS('tag',function(component)
    -- code
end)
```

This is the recommended way to get the *first* component on a tag in PlayerGui:
```lua
MCS('tag')
```

Note the function, by excluding it you can shortcut this function to return a get instead of a create

Standard API:

```lua
MCS:Get(GuiObject)
    -- Returns the component on a UI object

MCS:GetAll('string')
    -- Returns all components, in a table, on a given tag

MCS:GetComponent('string')
    -- Returns the first component on a tag in the PlayerGui

MCS:Fire('string', ...)
    -- Fire a binded function on a given name

MCS:Create('string', function)
    -- Create the component & pass it in the function

MCS('string', function)
    -- See MCS:Create

MCS('string')
    -- See MCS:GetComponent
```

## Component Documentation
Components are passed within the function connected to `MCS:Create(tag, func)` [ `MCS(tag, func)` ]

Standard API:

```lua
component:Bind('string', function)
    -- Bind a function to the given name

component:Unbind('string')
    -- Unbind the function on the given name

component:Fire('string', ...)
    -- Fire a function binded on a name with any extra parameters to pass

component:Get('string')
    -- Returns a component state located as an attribute or ValueBase on/in a Configuration [a class]

component:Set('string', variant)
    -- Set a variant on an already existing ValueBase or create an attribute

component:Update('string', variant)
    -- Similar to :Set, this API will increment numbers but set everything else & requires the state to already be existing

component:Attribute('string', function)
    --[[
    Don't be scared of the name, Attribute hooks a function to a given name on an already
    existing attribute or ValueBase. Unlike Roblox, I pass the changed value. Please support:
    https://devforum.roblox.com/t/getpropertychangedsignal-should-include-the-new-value-in-the-callback/108616/11?u=mullets_gavin
    ]]--
    
component:Connect(GuiObject, 'string', function)
    -- Connect a valid event to a GuiObject & hook the function, for example:
    component:Connect(TextButton, 'MouseButton1Click', function()
        print('click!')
    end)

component:Lifecycle('name', function)
    -- This Lifecycle method binds a function to RenderStepped & runs the code as long as the element is Visible = true

component('string')
    -- See component:Get

component('string', variant)
    -- See component:Set

component.[index]
    --[[
    A custom index function which allows you to provide unknown children/props to the index
    on the component. This allows you to set everything on the same level:
    
    Heirarchy:
        Frame -- this is the tagged component
        └─ Title -- this is a direct child
    
    component.Frame.Title == component.Title
    ]]--
```

## Animator Documentation
Simply use Tiffany's tag editor & apply the tags listed below
to GuiObjects which take the given events!

Tag editor:
https://www.roblox.com/library/948084095/Tag-Editor

How to add more events:

This lib is very flexible & allows you to set your own functions! Simply
create a new function with the following format:

```lua
Animator['tag_name'] = function(element: GuiObject): nil
    -- code
end
```

This follows the Luau typed standard & also provides the GuiObject. You should not be setting
UI_ in front of the tag in the function, this is set upon run time when searching for tags.