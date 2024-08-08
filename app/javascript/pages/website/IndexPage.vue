<template>
  <div>
    <div class="container-features">
      <div class="container-image">
        <img src="/portrait.jpg" alt="portrait" />
        <div class="shadow-image collab">
          <p>Shoot.</p>
          <p class="ml-3 text-lg">Select.</p>
          <p class="ml-6 mt-4 text-5xl">Shoot<strong>Select</strong></p>
        </div>
      </div>
    </div>
    <div class="collab grid grid-cols-1 lg:grid-cols-2 mx-16 mt-36">
      <div class="border border-solid border-r-0 border-violet-500">
        <img src="/teamwork.webp" alt="headshot" class="w-full h-fit" />
      </div>
      <!-- </div> -->
      <ul
        class="p-16 pt-24 text-sm sm:text-md md:text-xl flex flex-col gap-4 border border-solid border-l-0"
      >
        <li class="text-base md:text-lg xl:text-xl 2xl:text-2xl">
          After a photoshoot, do you have to:
        </li>
        <li class="flex gap-3 items-center">
          <font-awesome-icon
            icon="fa-solid fa-check"
            class="sm:text-lg md:text-xl text-violet-500"
          />
          <div>
            Select from
            <strong class="md:text-lg xl:text-xl 2xl:text-2xl">hundreds of photos</strong>?
          </div>
        </li>
        <li class="flex gap-3 items-center">
          <font-awesome-icon icon="fa-solid fa-check" class="text-xl text-violet-500" />
          <div class="w-full">
            Decide in <strong class="md:text-lg xl:text-xl 2xl:text-2xl">collaboration</strong> with
            <div class="lg:truncate lg:text-ellipsis lg:overflow-hidden xl:flex xl:items-baseline">
              <span
                v-for="(
                  letter, i
                ) in 'clients, editors, creative director, art directors, designer, team members'"
                :key="i"
                :style="{
                  fontSize: 1.25 - i * 0.01 + 'rem',
                }"
              >
                {{ letter }}
              </span>
              ?
            </div>
          </div>
        </li>
        <li class="flex gap-3 items-center">
          <font-awesome-icon icon="fa-solid fa-check" class="text-xl text-violet-500" />
          <div>
            Chain yourself to a
            <strong class="md:text-lg xl:text-xl 2xl:text-2xl">big work station</strong> all day
            long?
          </div>
        </li>
        <li class="flex gap-3 items-center">
          <font-awesome-icon icon="fa-solid fa-check" class="text-xl text-violet-500" />
          <div>
            <strong class="md:text-lg xl:text-xl 2xl:text-2xl">Pay</strong> for collaborative review
            tools?
          </div>
        </li>
      </ul>
    </div>
    <div class="flex justify-center py-24 text-5xl">
      <div>
        <div class="text-xl">then</div>
        This is For You.
      </div>
      <!-- When moving the mouse over the text, the text should change to "ShootSelect" -->
    </div>
    <div class="simple-review grid grid-cols-2">
      <div class="flex justify-center">
        <img src="/appUI.jpg" alt="portrait" />
      </div>
      <div class="bg-white border border-solid text-black pl-16">
        <p class="mt-40 mb-8 text-4xl">Photo culling is <strong>simple</strong>.</p>
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

    <div class="grid md:grid-cols-2 gap-8 px-16 select mt-20">
      <div class="container-image multiplatform collab relative">
        <img
          src="/desktopOffice 2.jpeg"
          alt="desktop office"
          class="w-3/5 opacity-50"
          style="filter: blur(1px)"
        />
        <div class="w-3/5 h-full z-20 absolute left-0 top-0">
          <div class="flex h-full justify-center items-center">
            <font-awesome-icon
              icon="fa-solid fa-check"
              class="sm:text-lg md:text-xl text-violet-500"
            />
          </div>
        </div>
      </div>
      <div class="container-image multiplatform collab relative flex justify-end">
        <img
          src="/laptopCafe.webp"
          alt="laptop cafe"
          class="w-3/5 opacity-50"
          style="filter: blur(1px)"
        />
        <div class="w-3/5 h-full z-20 absolute left-0 top-0">
          <div class="flex h-full justify-center items-center">
            <font-awesome-icon
              icon="fa-solid fa-question"
              class="sm:text-lg md:text-xl text-violet-500"
            />
          </div>
        </div>
      </div>
      <div class="container-image multiplatform collab relative">
        <img
          src="/phoneTrain.jpeg"
          alt="phone train"
          class="w-3/5 opacity-50"
          style="filter: blur(1px)"
        />
        <div class="w-3/5 h-full z-20 absolute left-0 top-0">
          <div class="flex h-full justify-center items-center">
            <font-awesome-icon
              icon="fa-solid fa-xmark"
              class="sm:text-lg md:text-xl text-violet-500"
            />
          </div>
        </div>
      </div>
      <div class="container-image multiplatform collab relative flex justify-end">
        <img
          src="/phoneHome.webp"
          alt="phone home"
          class="w-3/5 opacity-80"
          style="filter: blur(1px)"
        />
        <div class="w-3/5 h-full z-20 absolute left-0 top-0">
          <div class="flex h-full justify-center items-center">
            <font-awesome-icon
              icon="fa-solid fa-check"
              class="sm:text-lg md:text-xl text-violet-500"
            />
          </div>
        </div>
      </div>
    </div>

    <div class="container-features border border-solid mt-20">
      <div class="container-image">
        <img src="/photocrew.webp" alt="portrait" />
        <div class="shadow-image">
          <p class="ml-2">Shoot.</p>
          <p class="ml-6 text-lg">Select.</p>
          <p class="ml-8 mt-4 text-3xl">Shoot<strong>Select</strong></p>
        </div>
      </div>
    </div>
    <div class="container-features select border border-solid mt-20">
      <div class="container-image select">
        <img src="/select.webp" alt="portrait" />
      </div>
    </div>
    <div class="contact border border-solid">Contact us</div>
  </div>
</template>

<script setup lang="ts">
const reviewDisplayOptions = [
  { value: 'Yes', icon: 'check' },
  { value: 'No', icon: 'xmark' },
  { value: 'Maybe', icon: 'question' },
];
</script>

<style scoped>
@import '../../assets/css/base.css';

.container-features {
  display: flex;
  justify-content: center;
  width: auto;
  position: relative;
  z-index: 0;
  &.select,
  &.collab {
    background-color: white;
    color: var(--black-photobg);

    .container-image .shadow-image {
      box-shadow: none;
    }
  }

  .container-image {
    position: relative;
    height: calc(100vh - 8.5rem);
    max-height: calc(100vh - 8.5rem);
    img {
      height: 100%;
      max-height: calc(100vh - 8.5rem);
      width: auto;
      position: relative;
      z-index: 0;
      margin: 0 auto;
    }
    .shadow-image {
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
      height: 100%;
      width: 100%;
      box-shadow: inset -20px 2px 50px 50px var(--black-photobg);
    }
  }
}
</style>
