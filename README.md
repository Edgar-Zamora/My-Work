<!-- Slideshow container -->

<div class="slideshow-container">

<!-- Full-width images with number and caption text -->

<div class="mySlides fade">

    <div class="numbertext"></div>
    <img src="https://images.unsplash.com/photo-1510218129079-74e00c5a90ea?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=375&q=80" style="width:100%">
    <div class="text">Caption Text</div>

</div>

<div class="mySlides fade">

    <div class="numbertext"></div>
    <img src="https://images.unsplash.com/photo-1610510385151-df4f330a2dcb?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=815&q=80" style="width:100%">
    <div class="text">Caption Two</div>

</div>

<div class="mySlides fade">

    <div class="numbertext"></div>
    <img src="https://images.unsplash.com/photo-1610350532987-c4d261d3a6d2?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80" style="width: 100%">
    <div class="text">Caption Three</div>

</div>

<!-- Next and previous buttons -->
<a class="prev" onclick="plusSlides(-1)">❮</a>
<a class="next" onclick="plusSlides(1)">❯</a>

</div>

<br>

<!-- The dots/circles -->

<div style="text-align:center">

<span class="dot" onclick="currentSlide(1)"></span> <span class="dot"
onclick="currentSlide(2)"></span> <span class="dot"
onclick="currentSlide(3)"></span>

</div>

``` js
var slideIndex = 0;
showSlides();

function showSlides() {
  var i;
  var slides = document.getElementsByClassName("mySlides");
  for (i = 0; i < slides.length; i++) {
    slides[i].style.display = "none"; 
  }
  slideIndex++;
  if (slideIndex > slides.length) {slideIndex = 1} 
  slides[slideIndex-1].style.display = "block"; 
  setTimeout(showSlides, 5000); // Change image every 2 seconds
}
```
