(function (window, document) {
    function findPostsByTag(needle) {
        var posts = document.getElementsByClassName("post"), post, tag, i, l = posts.length, needles = needle.split(" ");
        for (i = 0; i < l; i++) {
            post = posts[i];
            tag = post.getElementsByClassName("post-tags")[0];
            post.style.display = (tag && matchTag(tag.innerText + ",", needles))? '': 'none';
        }
        window.msnry.layout();
    }
    function matchTag(haystack, needles) {
        for (var i = 0, l = needles.length; i < l; i++) {
            var needle = needles[i];
            if (needle && haystack.indexOf(needle) > -1) {
                return true;
            }
        }
        return false;
    }
    function showAllPosts() {
        var posts = document.getElementsByClassName("post"), post, i, l = posts.length;
        for (i = 0; i < l; i++) {
            post = posts[i];
            post.style.display = '';
        }
        window.msnry.layout();
    }

    document.getElementById("search").addEventListener("keyup", function (ev) {
        var needle = ev.target.value;
        if (needle) {
            findPostsByTag(needle);
        } else {
            showAllPosts();
        }
        return false;
    });
})(window, window.document);
