function routeHandler(route) {
    // remove active class and add class active to current menu item
    document.querySelector('.menu a.active').classList.remove('active');
    document.querySelector(`.menu a[href="#${route}"]`).classList.add('active');

    const iframe = document.getElementById('main-frame');

    // change iFrame source
    if(route === 'welcome'){
        iframe.src = 'welcome.html';
    } else {
        iframe.src = route;
    }
}

function locationHashChanged() {
    (location.hash === "#welcome") &&  routeHandler('welcome');
    (location.hash === "#flood") && routeHandler('flood');
    (location.hash === "#cockpit") && routeHandler('cockpit');  
}

// on route change call function
window.onhashchange = locationHashChanged;
locationHashChanged();

// onclick remove all active classes and add class active to current element 
document.querySelectorAll('.menu ul li a').forEach(element => {
    element.addEventListener('click', function() {
        document.querySelector('a.active').classList.remove('active');
        this.classList.add('active');
    });
});

// load icons
feather.replace();
