import { Component, createApp } from 'vue';
import { Router } from 'vue-router';
import { VueQueryPlugin } from 'vue-query';
/* import font awesome icon component */
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
/* import the fontawesome core */
import { library } from '@fortawesome/fontawesome-svg-core'
/* import specific icons */
import { faPlus, faX, faHouse, faBell, faGear, faUser, faPen, faCalendarDays, faFloppyDisk, faCheck, faXmark, faQuestion, faCaretRight, faCaretLeft, faCaretDown, faArrowLeft, faExclamation, faRotateLeft, faGripLines, faTableColumns, faCircleCheck, faShareFromSquare, faEllipsis, faBorderAll, faList, faEye, faEyeSlash} from '@fortawesome/free-solid-svg-icons'
import { faTrashCan, faSquareMinus } from '@fortawesome/free-regular-svg-icons'

import { globalProperties } from './globalProperties';
import { pinia } from '@/stores';
import { setHTTPHeader } from '@/services/http.service';
import AuthService from '@/services/auth.service';

/* add icons to the library */
library.add(faPlus, faX, faHouse, faBell, faGear, faUser, faPen, faCalendarDays, faFloppyDisk, faCheck, faXmark, faQuestion, faCaretRight, faCaretLeft, faCaretDown, faArrowLeft, faExclamation, faRotateLeft, faGripLines, faTableColumns, faCircleCheck, faShareFromSquare, faEllipsis, faBorderAll, faList, faEye, faEyeSlash)
library.add( faTrashCan, faSquareMinus )
const token = AuthService.getToken();

if (token) {
  setHTTPHeader({ Authorization: token });
}

export const setupEntryPoint = (rootComponent: Component, router: Router) => {
  const app = createApp(rootComponent);

  app.use(router);
  app.use(pinia);
  app.component('font-awesome-icon', FontAwesomeIcon);
  app.use(VueQueryPlugin);
  app.config.globalProperties = { ...app.config.globalProperties, ...globalProperties }
  app.mount('#app');
};
