// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "content", "back", "other", 'last' ]

  revealContent(event) {
    event.preventDefault()

    this.otherTarget.classList.toggle("d-none")

    fetch(event.target.href, {
      headers: { "Accept": "text/plain" }
    })
    .then((res) => res.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
      var objDiv = document.getElementById("messages");
      objDiv.scrollTop = objDiv.scrollHeight;
    })
    this.contentTarget.classList.toggle("d-none")
  }

  createContent(event) {
    event.preventDefault()
    this.contentTarget.classList.toggle("d-none")
    event.stopImmediatePropagation()
    const csrf = document.querySelector('[name=csrf-token]').content
    fetch(event.target.href, {
      headers: { "Accept": "text/plain", 'X-CSRF-TOKEN': csrf },
      method: "POST"
    })
    .then((res) => res.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
      var objDiv = document.getElementById("messages");
      objDiv.scrollTop = objDiv.scrollHeight;
    })
    this.otherTarget.classList.toggle("d-none")
  }

  deleteContent(event) {
    let base_url = window.location.origin;
    let specific_url = window.location.pathname
    const complete_url = base_url + specific_url
    event.preventDefault()
    event.stopImmediatePropagation()
    window.history.pushState({}, document.title, "/" );
    const csrf = document.querySelector('[name=csrf-token]').content
    fetch(event.target.href, {
      headers: { "Accept": "text/plain", 'X-CSRF-TOKEN': csrf  },
      method: "DELETE",
    })
    .then((res) => res.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
      window.history.pushState({}, document.title, "/" );
      window.history.pushState({}, document.title, complete_url );
    })
  }


  displayBack() {
    let base_url = window.location.origin;
    let specific_url = window.location.pathname
    const complete_url = base_url + specific_url
    window.history.pushState({}, document.title, "/" );
    fetch("chatrooms", {
      headers: { "Accept": "text/plain" }
    })
    .then((res) => res.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
      window.history.pushState({}, document.title, complete_url );
    })
    // this.otherTarget.classList.toggle("d-none")
  }
}
