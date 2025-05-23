module ProductCard exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

type alias Flags =
    { imageUrls : List Image
    , productName : String
    , price : String
    , colors : List ColorOption
    , description : String
    , badge : {
        text: String,
        classnames: String
    }
    }

type alias Image = 
    { name: String
    , url: String
    }

type alias ColorOption = 
    { name: String
    , hexCode: String
    }

-- Model
type alias Model = { imageUrls : List Image
    , productName : String
    , price : String
    , colors : List ColorOption
    , description : String
    , badge : {
        text : String,
        classnames : String
    }
    , selectedImageUrl : String
    , selectedColor : ColorOption
    }

-- Msg
type Msg = SelectColor ColorOption

-- init
init: Flags -> (Model, Cmd Msg)
init flags = 
    let initialModel = 
            { imageUrls = flags.imageUrls
            , productName = flags.productName
            , price = flags.price
            , colors = flags.colors
            , description = flags.description
            , badge = flags.badge
            , selectedImageUrl = 
                flags.imageUrls
                    |> List.head
                    |> Maybe.map(\image -> image.url)
                    |> Maybe.withDefault ""
            , selectedColor = 
                flags.colors
                    |> List.head
                    |> Maybe.map(\color -> color)
                    |> Maybe.withDefault { name = "", hexCode = "" }
            }
            
    in
    (initialModel, Cmd.none)

-- update
update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        SelectColor selectedColor ->
            let
                newImageUrl = 
                    List.filter(\image -> image.name == selectedColor.name) model.imageUrls
                        |> List.head
                        |> Maybe.map(\image -> image.url)
                        |> Maybe.withDefault model.selectedImageUrl 
            in
            ({ model | selectedImageUrl = newImageUrl, selectedColor = selectedColor }, Cmd.none)

-- view
view: Model -> Html Msg
view model = 
    div [ class "bg-[#f7f7f7] rounded-lg shadow-lg overflow-hidden w-72 pb-4" ]
    [ div [ class "relative " ]
        [ img [ src model.selectedImageUrl, alt model.productName, class "w-full h-48 object-contain"  ][]
        , if String.length model.badge.text > 0 then
                span [ class ("absolute top-3 left-3 text-white py-1 px-2.5 text-xs font-medium rounded " ++ model.badge.classnames) ] [ text model.badge.text ]
              else
                Html.text ""
        ]
    , div [ class "p-4 pb-0" ]
        [ h2 [ class "text-lg font-semibold mt-0 mb-1 text-gray-800" ]
            [ text model.productName ]
        , span [ class "text-xl font-bold text-black mb-3 block" ]
            [ text model.price ]
        , viewColorOptions model.selectedColor model.colors
        , p [ class "text-sm text-gray-600 leading-normal" ]
            [ text model.description ]
        ]
    ]

viewColorOptions: ColorOption -> List ColorOption -> Html Msg
viewColorOptions selectedColor colors =
    div [ class "mb-3 flex items-center gap-1.5"]
    (List.map (viewColorOption selectedColor) colors)

viewColorOption: ColorOption -> ColorOption -> Html Msg
viewColorOption selectedColorOption color =
    let
        baseClasses = "block relative appearance-none p-0 cursor-pointer rounded-full border-0 border-solid bg-cover flex-none w-[19px] h-[19px] outline outline-2 outline-solid outline-transparent outline-offset-[-3px] focus:outline-white active:outline-white bg-[" ++ color.hexCode ++ "]"
        selectedSpecificStyling = "[&.selected]:outline-white"
        isSelected = selectedColorOption == color
        finalClasses =
            if isSelected then
                baseClasses ++ " " ++ selectedSpecificStyling ++ " selected"
            else
                baseClasses
    in
    button
        [ class finalClasses
        , style "background-color" color.hexCode
        , onClick (SelectColor color)
        , Html.Attributes.attribute "data-testid" ("color-button-" ++ String.toLower color.name)
        ]
        []
    
-- Main

main: Program Flags Model Msg
main = 
    Browser.element{
        init = init,
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none
    }



