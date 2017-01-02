import Foundation
import Leaf
import Node
import Vapor
import VaporForms

public enum Error: Swift.Error {
    case parse
}

public class FormCheckboxGroup: BasicTag {
    public init(){}
    public let name = "form:checkboxgroup"
    
    public func run(arguments: [Argument]) throws -> Node? {
        
        /*
         #form:checkboxgroup(key, value, fieldset)
         
         Arguments:
         [0] = The name of the input (the key that gets posted) *
         [1] = The value of the input (the value that gets posted) (defaults to empty string) *
         [2] = The VaporForms Fieldset of the entire model * **
         
         * - All the arguments are actually required. We need to throw exceptions at people if they don't supply all of them
         ** - It would be awesome if you could only post the exact Field of the Fieldset so we don't need to find it in this code (its gonna get repetetive)
         
         The <label> will get its value from the Fieldset
         
         Checkboxes currently does not support validation
         
         given input:
         
         let fieldset = Fieldset([
            "sendMail": StringField(
                label: "Send Welcome Mail to User"
            )
         ])
         
         #form:checkboxgroup("sendMail", false, fieldset)
         
         expected output if value is true:
         <div class="checkbox">
            <label>
                <input type="checkbox" name="sendMail" value="true" checked>
                Send Welcome Mail to User
            </label>
        </div>
         
         expected output if fieldset is false:
         <div class="checkbox">
            <label>
                <input type="checkbox" name="sendMail" value="false">
                Send Welcome Mail to User
            </label>
         </div>
        */
        

        guard arguments.count == 3,
            let inputName: String = arguments[0].value?.string,
            let fieldsetNode = arguments[2].value?.nodeObject
        else {
            throw Error.parse
        }
        
        let inputValue = ""
        
        let fieldset = fieldsetNode[inputName]
        
        let label = fieldset?["label"]?.string ?? inputName
        
        // This is not a required property
        //let errors = fieldset?["errors"]?.pathIndexableArray
        
        // Start constructing the template
        var template = [String]()

        template.append("<div class='form-group \(errors != nil ? "has-error" : "")'>")
        
        template.append("<label class='control-label' for='\(inputName)'>\(label)</label>")
        
        template.append("<input class='form-control' type='text' id='\(inputName)' name='\(inputName)' value='\(inputValue)' />")
      
        // If Fieldset has errors then loop through them and add help-blocks
        if(errors != nil) {
            for e in errors! {
                
                guard let errorString = e.string else {
                    continue
                }
                
                template.append("<span class='help-block'>\(errorString)</span>")
            }
        }
        
        template.append("</div>")
        
        // Return template
        return .bytes(template.joined().bytes)
    }
}
