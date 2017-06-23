import virtualStyles from "./virtualStyles.json";

const convertVirtualClassnames = classNames => {
  return classNames
    .split(" ")
    .map(
      className =>
        // If mapping exists, use that. Else leave it as is
        virtualStyles[className] || className
    )
    .join(" ");
};

export default convertVirtualClassnames;
