
try{

    let all_stars = document.querySelectorAll('.fa-star');
    let star_count = document.querySelector('#star_count');
    all_stars.forEach(function(star){
        star.addEventListener('mouseover',function(){
            let star_id = star.getAttribute('id');
            let star_id_num_int = parseInt(star_id);
            let all_stars_int = all_stars.length;
            for(let i = 0; i < all_stars_int; i++){
                if(i <= star_id_num_int){
                    all_stars[i].classList.add('checked');
                }else{
                    all_stars[i].classList.remove('checked');
                }
            }
        }
        );
        star.addEventListener('mouseout',function(){
            let star_id = star.getAttribute('id');
            let star_id_num_int = parseInt(star_id);
            let all_stars_int = all_stars.length;
            for(let i = 0; i < all_stars_int; i++){
                if(i <= star_id_num_int){
                    all_stars[i].classList.add('checked');
                }else{
                    all_stars[i].classList.remove('checked');
                }
            }
        }
        );

        star.addEventListener('click',function(){
            let star_id = star.getAttribute('id');
            let star_id_num_int = parseInt(star_id);
            let all_stars_int = all_stars.length;
            star_count.innerHTML = star_id_num_int+1;
            for(let i = 0; i < all_stars_int; i++){
                if(i <= star_id_num_int){
                    all_stars[i].classList.add('checked');
                }else{
                    all_stars[i].classList.remove('checked');
                }
            }
        }
        );
    });

    let add_rating_button = document.querySelector('#add_rating');
    add_rating_button.addEventListener('click',function(){
        let star_count_int = parseInt(star_count.innerHTML);
        console.log(star_count_int);
        let game_id = document.location.href.split('/')[4];
        let url = '/games/'+game_id+'/rating/add/'+star_count_int;
        // send form
        let xhr = new XMLHttpRequest();
        xhr.open('POST',url,true);
        xhr.onreadystatechange = function(){
            if(xhr.readyState == 4 && xhr.status == 200){
                let response = JSON.parse(xhr.responseText);
                if(response.success){
                    alert('Rating added');
                }else{
                    alert('Rating not added');
                }
            }
        }
    });
}
catch(err){
    alert(err);
}