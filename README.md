# My Work

<center>

🐦 <a href="https://twitter.com/Edgar_Zamora_">Twitter</a> | 📝 <a href="https://edgarzamora.netlify.com/">Blog</a> | 📧 <a href="mailto:edgarzamora2012@hotmail.com">Email</a> | 👔 <a href="https://www.linkedin.com/in/edgar-zamora-01896b148/">LinkedIn</a> 

</center>

<br>

A portfolio of my work to the <a href="https://github.com/rfordatascience/tidytuesday">#TidyTuesday</a> project and general `{tidyverse}` work. 

<br>

<img class="mySlides" src="https://raw.githubusercontent.com/Edgar-Zamora/My-Work/master/%23TidyTuesday/Australian%20Pets/australian_pets.jpeg">
<img class="mySlides" src="https://raw.githubusercontent.com/Edgar-Zamora/My-Work/master/%23TidyTuesday/NZ%20Bird%20of%20the%20Year/NZ_Bird_of_Year.jpeg">

<script>
var slideIndex = 0;
var slideIndex = 0;
carousel();

function carousel() {
  var i;
  var x = document.getElementsByClassName("mySlides");
  for (i = 0; i < x.length; i++) {
    x[i].style.display = "none"; 
  }
  slideIndex++;
  if (slideIndex > x.length) {slideIndex = 1} 
  x[slideIndex-1].style.display = "block"; 
  setTimeout(carousel, 10000);
}
</script>
