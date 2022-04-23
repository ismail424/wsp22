
try{

    let all_stars = document.querySelectorAll('.fa-star');
    let star_count = document.querySelector('#star_count');
    let rating_value  = document.querySelector('#rating_value');


    all_stars[0].classList.add('checked');

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
            rating_value.value = star_id_num_int+1;
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


  
}
catch(err){
    alert(err);
}