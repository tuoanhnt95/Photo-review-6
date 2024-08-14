<template>
  <div>
    <div class="container-features mt-24">
      <div class="container-image">
        <img src="/portrait.jpg" alt="portrait" />
        <div class="shadow-image">
          <div class="flex flex-col items-center">
            <p class="ml-2 mb-2 sm:text-lg">Collaborative Photo-culling App</p>
            <p class="sm:ml-3 text-3xl sm:text-4xl md:text-5xl">
              Select the best shots, <strong>together</strong>
            </p>
          </div>
        </div>
      </div>
    </div>

    <div id="pain-point" class="container-cols-2">
      <div class="img-left">
        <img src="/teamwork.webp" alt="headshot" class="w-full h-fit" />
      </div>
      <div class="content-right bg-violet-700">
        <ul class="w-5/6 md:w-3/4">
          <li class="text-base md:text-lg xl:text-xl 2xl:text-2xl">
            <div>After a shoot, do you <strong>dread photo culling</strong>?</div>
            In other words, do you have to:
          </li>
          <li
            v-for="(pain, i) in pains"
            :key="i"
            class="flex gap-3 items-center mt-4 md:mt-2 lg:mt-4"
          >
            <font-awesome-icon icon="fa-solid fa-check" />
            <div>
              {{ pain[0] }}
              <strong class="md:text-lg xl:text-xl 2xl:text-2xl">{{ pain[1] }}</strong>
              {{ pain[2] }}?
            </div>
          </li>
        </ul>
      </div>
    </div>
    <div class="flex justify-center py-24 text-5xl">
      <div>
        <div class="text-xl">then</div>
        <span class="text-violet-500">This</span> is For You.
      </div>
    </div>
    <div class="container-cols-2">
      <div class="flex justify-center">
        <img src="/appUI.jpg" alt="portrait" />
      </div>
      <!-- <div class="flex justify-content items-center bg-white text-black py-16 pl-16"> -->
      <div
        class="flex justify-center items-center lg:text-black py-36 md:py-0 md:block md:pt-36 md:pl-20 lg:pt-40 lg:pl-28 bg-white text-black"
      >
        <div>
          <p class="text-4xl md:text-2xl lg:text-3xl xl:text-4xl">
            Photo culling is <strong class="text-violet-700">simple</strong>.
          </p>
          <p class="text-2xl mb-2">All you have to do is select</p>
          <table>
            <tr v-for="opt in reviewDisplayOptions" :key="opt.value">
              <td>
                <div class="mb-2">
                  <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" class="text-2xl" />
                </div>
              </td>
              <td class="text-2xl pl-4">
                <div class="flex items-center">{{ opt.value }}</div>
              </td>
            </tr>
          </table>
          <div v-for="opt in reviewDisplayOptions" :key="opt.value" class="flex gap-4 items-center">
            <p></p>
          </div>
        </div>
      </div>
    </div>

    <div id="container-collabs" class="container-cols-2 my-12">
      <div class="img-left md:pr-0">
        <div v-for="(collab, i) in collabs" :key="i" class="container-collab">
          <img :src="collab.src" :alt="collab.alt" />
          <div class="container-icon" :class="i % 2 === 0 ? 'flex justify-end' : ''">
            <div class="icon">
              <font-awesome-icon :icon="`fa-solid fa-${collab.icon}`" />
            </div>
          </div>
        </div>
      </div>
      <div class="content-right flex justify-center items-center border border-solid">
        <div>
          <div class="w-full flex justify-center pt-8 pb-2 text-3xl">
            Any<strong class="tracking-wider">one</strong>. Any<strong class="tracking-wider"
              >time</strong
            >. Any<strong class="tracking-wider">where</strong>.
          </div>
          <div class="w-full flex justify-center pb-8 text-xl">
            <strong class="mx-2">Collaborate</strong> to review more quickly and accurately.
          </div>
        </div>
      </div>
    </div>

    <div class="w-full flex flex-col items-center py-12 bg-violet-700 text-3xl">
      <p><strong>Free 1000 </strong>photos every <strong>30 days</strong>.</p>
      <p><strong>Unlimited</strong> albums.</p>
      <p><strong>Unlimited</strong> collaborators.</p>
    </div>
    <div class="w-full flex justify-center px-12 py-4 text-white text-xl">
      <p class="text-center">
        <strong>ShootSelect</strong> is free for everyone's basic use. Any
        <a
          href="https://jp.linkedin.com/in/oanhnguyenthitu"
          target="_blank"
          class="underline underline-offset-2"
          >support</a
        >
        is welcome!
      </p>
    </div>

    <div class="w-full flex justify-center my-12">
      <div class="w-1/2 py-12">
        <div class="text-5xl text-center">
          <p class="mb-4">Ready to</p>
          <p class="text-violet-500">ShootSelect?</p>
        </div>
        <div class="flex justify-center">
          <router-link
            :to="{ name: 'signup' }"
            class="btn-website bg-violet-500 hover:bg-violet-600 mt-8"
          >
            Get Started
          </router-link>
        </div>
      </div>
    </div>

    <div class="container-cols-2 mt-20 bg-white">
      <img src="/photocrew.webp" alt="portrait" />
      <div class="m-12 text-xl text-black">
        <div>
          <p class="mb-4 text-4xl">Contact</p>
          <ul>
            <li>
              <a href="mailto:tuoanhnt95@gmail.com">
                <font-awesome-icon icon="fa-regular fa-envelope" />
                : tuoanhnt95@gmail.com
              </a>
            </li>
            <li>
              <a href="https://jp.linkedin.com/in/oanhnguyenthitu" target="_blank">
                <font-awesome-icon icon="fa-brands fa-linkedin-in" />: Oanh Nguyen Thi Tu
              </a>
            </li>
          </ul>
        </div>
        <div class="mt-8">
          <p class="mb-4 text-3xl">About creator</p>
          <p class="mb-1">Oanh Nguyen is a story teller and software developer who enjoys:</p>
          <li class="mb-1">photography</li>
          <li class="mb-1">collaborations</li>
          <li class="mb-1">
            creating tools to help <span class="line-through">herself</span>
            <span class="line-through">others</span>.
          </li>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const pains = [
  ['Select from', 'hundreds of photos', ''],
  [
    'Communicate',
    'back and forth',
    'with clients, editors, creative director, art directors, designer, etc.',
  ],
  ['Chain yourself to an', 'overkill workstation', 'all day'],
  ['', 'Pay', 'for collaborative review tools'],
];

const reviewDisplayOptions = [
  { value: 'Yes', icon: 'check' },
  { value: 'No', icon: 'xmark' },
  { value: 'Maybe', icon: 'question' },
];

const collabs = [
  { src: '/desktopOffice 2.jpeg', alt: 'desktop office', icon: 'check' },
  { src: '/laptopCafe.webp', alt: 'laptop cafe', icon: 'question' },
  { src: '/phoneTrain.jpeg', alt: 'phone train', icon: 'xmark' },
  { src: '/phoneHome.webp', alt: 'phone home', icon: 'check' },
];
</script>

<style scoped>
@import '../../assets/css/base.css';

.container-cols-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
}

.container-features {
  display: flex;
  justify-content: center;
  width: auto;
  position: relative;
  z-index: 0;

  .container-image {
    position: relative;
    height: fit-content;
    max-height: calc(100vh - 8.5rem);
    img {
      object-fit: contain;
      height: 100%;
      max-height: calc(100vh - 8.5rem);
      width: auto;
      position: relative;
      z-index: 0;
      margin: 0 auto;
    }
    .shadow-image {
      object-fit: contain;
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
      height: 100%;
      max-height: calc(100vh - 8.5rem);
      width: 100%;
      box-shadow: inset -20px 2px 50px 50px var(--black-photobg);
    }
  }
}

#pain-point {
  padding: 9rem 6rem 0 6rem;

  .img-left {
    border: 1px solid var(--violet-500);
  }

  .content-right {
    display: flex;
    justify-content: center;
    align-items: center;
  }
}

#container-collabs {
  .img-left {
    display: grid;
    grid-template-columns: 1fr 1fr;
    padding: 4rem;

    .container-collab {
      position: relative;
      height: 100%;
      img {
        height: 100%;
        width: auto;
        filter: blur(1px) grayscale(0.5);
      }

      .container-icon {
        position: absolute;
        top: 0;
        left: 0;
        height: 100%;
        width: 100%;
        z-index: 2;
        display: flex;
        justify-content: center;
        align-items: center;

        .icon {
          background-color: var(--black-photobg);
          border-radius: 50%;
          height: 3rem;
          width: 3rem;
          display: flex;
          justify-content: center;
          align-items: center;

          svg {
            color: var(--violet-500);
            font-weight: 900;
            font-size: 1.875rem; /* 30px */
            line-height: 2.25rem; /* 36px */
          }
        }
      }
    }
  }
}

@media screen and (max-width: 767px) {
  .container-cols-2 {
    grid-template-columns: 1fr;
  }
}

@media screen and (max-width: 1023px) {
  #pain-point {
    padding: 6rem 3rem 0 3rem;
  }
}

@media screen and (max-width: 839px) {
  #pain-point {
    .content-right {
      padding-top: 2rem;
      padding-bottom: 2rem;
    }
  }
}
@media screen and (min-width: 840px) {
  #container-cols-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
}
</style>
