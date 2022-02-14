//Game card hover effect - (Read more effect)
let game_card = document.getElementsByClassName("game_card");
for (let i = 0; i < game_card.length; i++) {
    game_card[i].addEventListener("mouseover", function () {
        game_card[i].children[1].style = "display:block";
    });
    game_card[i].addEventListener("mouseout", function () {
        game_card[i].children[1].style = "display:none";
    });
}
