FROM node:18-slim

RUN mkdir -p /app
WORKDIR /app
COPY . /app

RUN npm install
# RUN npm run build

EXPOSE 3000

ENTRYPOINT npm run serve -- --build --port 3000 --host 0.0.0.0

# # Use the official Node.js 14 as a parent image
# FROM node:18 as build

# # Set the working directory
# WORKDIR /app

# # Copy package.json and package-lock.json (or yarn.lock) files
# COPY package*.json ./
# # If you're using yarn, uncomment the next line and remove the npm install line
# # COPY yarn.lock ./

# # Install dependencies
# RUN npm install
# # If you're using yarn, uncomment the next line and remove the npm install line
# # RUN yarn install

# # Copy the rest of your Docusaurus project
# COPY . .

# # Build your site
# RUN npm run build
# # If you're using yarn, uncomment the next line and remove the npm run build line
# # RUN yarn build

# # Use serve to serve the site on port 3000
# FROM node:18-slim
# WORKDIR /app
# COPY --from=build /app/build /app
# RUN npm install -g serve
# CMD ["serve", "-s", "/app", "-l", "3000"]
# EXPOSE 3000